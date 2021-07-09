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

SMARTPHONE_VIDEO_DIR="smartphone_video_frames"

# Import configuration values
source configs/full-bandeja.conf
# Activate virtual environment
source venv/bin/activate
source /opt/ros/melodic/setup.bash

BAG=$1
SMARTPHONE_VIDEO_PATH=$2


if [ ! -f "$BAG" ]; then
  echo "Provided .bag file doesn't exist"
  exit
fi

SEQUENCE_TIMESTAMPS=()
DATA_DIR="output/$(basename "$BAG" .bag)"


## Create a subdirectory for extraction
rm -rf "$DATA_DIR"
mkdir -p "$DATA_DIR"


python2 extract.py --output "$DATA_DIR"\
  --type time_ref --path "$BAG" --topics "$SEQUENCE_TOPIC" 

# while IFS=, read -r seq timestamp col3
# do
#     echo "Sequence: $seq | starts with $timestamp"
#     SEQUENCE_TIMESTAMPS=("${SEQUENCE_TIMESTAMPS[@]}" "$timestamp")
# done < "./$DATA_DIR"/_sequences_ts/time_ref.csv

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
  # Image timestamps alignment
#  for topic in "${IMG_TOPICS[@]}"
#  do
#    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_cameras_ts/time_ref.csv\
#     --target_dir "./$DATA_DIR/${topic//\//_}" --align_type ref  --ref_seq 12
#  done
fi

# Depth image extraction
echo "Depth image data extraction starting.."
if [ ${#DEPTH_IMG_TOPICS[@]} -eq 0 ]; then
  echo "No depth image topics provided"
else
  python2 extract.py --output "$DATA_DIR"\
    --type depth_img --path "$BAG" --topics "${DEPTH_IMG_TOPICS[@]}"
  # Depth image timestamps alignment
#  for topic in "${DEPTH_IMG_TOPICS[@]}"
#  do
#    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_cameras_ts/time_ref.csv\
#     --target_dir "./$DATA_DIR/${topic//\//_}" --align_type ref  --ref_seq 12
#  done
fi

# IMU data extraction
echo "IMU data extraction starting.."
python2 extract.py --output "$DATA_DIR"\
  --type imu --path "$BAG" --topics "${IMU_TOPICS[@]}" --temp "${TEMP_TOPICS[@]}"

# Camera info data extraction
echo "Camera info extraction starting.."
python2 extract.py --output "$DATA_DIR"\
  --type cam_info --path "$BAG" --topics "${CAM_INFO_TOPICS[@]}"

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

# Smartphone data extraction
if [ -z "$2" ]; then
    >&2 echo "No smartphone video argument supplied"
else
  # Create target directory, extract video frames
  rm -rf "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
  mkdir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
  # Check if video exists
  if [ ! -f "$SMARTPHONE_VIDEO_PATH" ]; then
    >&2 echo "Provided smartphone video doesn't exist"
  else
    # ffmpeg -i "$SMARTPHONE_VIDEO_PATH" -vsync 0 "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR/frame-%d.png"

    # Sm data alignment
    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
      --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type csv  --vid "$SMARTPHONE_VIDEO_PATH"

    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
      --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type flash  --vid "$SMARTPHONE_VIDEO_PATH" 
    
    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
      --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type accel  --vid "$SMARTPHONE_VIDEO_PATH"

    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
      --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type gyro  --vid "$SMARTPHONE_VIDEO_PATH"

    cp "$SMARTPHONE_VIDEO_PATH" "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR/$(basename "$SMARTPHONE_VIDEO_PATH")"
    # python2 extract.py --output "$DATA_DIR"\
    #  --type sm_frames --path "$BAG" --frame_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --vid "$SMARTPHONE_VIDEO_PATH"
  fi
fi

# Azure data alignment
echo "Azure data alignment starting.."
if [ ${#AZURE_ALIGN_TOPICS[@]} -eq 0 ]; then
  >&2 echo "No azure topics provided"
else
  for topic in "${AZURE_ALIGN_TOPICS[@]}"
  do
    echo ./"$DATA_DIR"/_mcu_cameras_ts/time_ref.csv
    echo "./$DATA_DIR/${topic//\//_}"
    python2 align.py --time_ref_file ./"$DATA_DIR"/_depth_to_mcu_offset/time_ref.csv\
      --target_dir "./$DATA_DIR/${topic//\//_}" --align_type delta
  done
fi

# Kill roscore running in background
killall roscore
