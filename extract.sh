#!/bin/bash
set -eo pipefail

SMARTPHONE_VIDEO_DIR="_s10_video_frame"

# Import configuration values
source extract.conf
# Activate virtual environment
source venv/bin/activate
# Launch roscore in background
roscore &

BAG=$1
SMARTPHONE_VIDEO_PATH=$2

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

if [ ${#IMG_TOPICS[@]} -eq 0 ] ; then
  echo "No image topics provided"
else
  python2 extract.py --output "$DATA_DIR"\
  --type image --path "$BAG" --topics "${IMG_TOPICS[@]}"
fi

# Depth image extraction
echo "Image data extraction starting.."
if [ ${#DEPTH_IMG_TOPICS[@]} -eq 0 ] ; then
  echo "No image topics provided"
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
if [ -z "$1" ]
  then
    echo "No smartphone video argument supplied"
  else
    # Create target directory, extract video frames
    rm -rf "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
    mkdir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR"
    ffmpeg -i "$SMARTPHONE_VIDEO_PATH" "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR/frame-%d.png"
    python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_s10_ts/time_ref.csv\
     --target_dir "./$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --align_type delta --video_path "$SMARTPHONE_VIDEO_PATH"
fi

# IMU data extraction
echo "IMU data extraction starting.."
python2 extract.py --output "$DATA_DIR"\
  --type imu --path "$BAG" --topics "${IMU_TOPICS[@]}" --temp "${TEMP_TOPICS[@]}"

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