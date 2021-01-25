#!/bin/bash
# Copyright 2020 Mobile Robotics Lab. at Skoltech
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eo pipefail

SMARTPHONE_VIDEO_DIR="_s10_video_frame"

# Import configuration values
source extract.conf
# Activate virtual environment
source venv/bin/activate

BAG=$1
SMARTPHONE_VIDEO_PATH=$2

if [ ! -f "$BAG" ]; then
  echo "Provided .bag file doesn't exist"
  exit
fi

DATA_DIR="$(basename "$BAG" .bag)"

# Create a subdirectory for extraction
rm -rf "$DATA_DIR"
mkdir "$DATA_DIR"

# Time reference data extraction
echo "Time reference data extraction starting.."
python2 extract.py --output "$DATA_DIR"\
  --type time_ref --path "$BAG" --topics "${TIME_REF_TOPICS[@]}"

# Image extraction
echo "Image data extraction starting.."

if [ ${#IMG_TOPICS[@]} -eq 0 ]; then
  echo "No image topics provided"
else
  python2 extract.py --output "$DATA_DIR"\
  --type image --path "$BAG" --topics "${IMG_TOPICS[@]}"
fi

# Depth image extraction
echo "Depth image data extraction starting.."
if [ ${#DEPTH_IMG_TOPICS[@]} -eq 0 ]; then
  echo "No depth image topics provided"
else
  python2 extract.py --output "$DATA_DIR"\
    --type depth_img --path "$BAG" --topics "${DEPTH_IMG_TOPICS[@]}"
  # Depth image timestamps alignment
  for topic in "${DEPTH_IMG_TOPICS[@]}"
  do
    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_cameras_ts/time_ref.csv\
     --target_dir "./$DATA_DIR/${topic//\//_}" --align_type ref  --ref_seq 12
  done
fi

# Smartphone data alignment
if [ -z "$2" ]; then
    echo "No smartphone video argument supplied"
else
  # Create target directory, extract video frames
  rm -rf "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
  mkdir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
  # Check if video exists
  if [ ! -f "$SMARTPHONE_VIDEO_PATH" ]; then
    echo "Provided smartphone video doesn't exist"
  else
    ffmpeg -i "$SMARTPHONE_VIDEO_PATH" "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR/frame-%d.png"
    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
     --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type delta --video_path "$SMARTPHONE_VIDEO_PATH"
  fi
fi

# IMU data extraction
echo "IMU data extraction starting.."
python2 extract.py --output "$DATA_DIR"\
  --type imu --path "$BAG" --topics "${IMU_TOPICS[@]}" --temp "${TEMP_TOPICS[@]}"

# Launch roscore in background
roscore &

# PointCloud extraction
echo "PointCloud data extraction starting.."
for topic in "${PCD_TOPICS[@]}"
do
  PCD_DIR="$DATA_DIR/${topic//\//_}"
  rm -rf "$PCD_DIR"
  mkdir "$PCD_DIR" &&
  rosrun pcl_ros bag_to_pcd "$BAG" "$topic" "$PCD_DIR"
  # Rename <secs.nsecs>.pcd files to match timestamp format
  for file in "$PCD_DIR"/*.*.pcd
  do
    suf=${file#*.}
    pref=${file%".$suf"}
    mv "$file" "$pref$suf"
  done
done

# Kill roscore running in background
killall roscore
