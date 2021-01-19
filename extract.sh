#!/bin/bash
set -evo pipefail

# TODO: move to config file
DEPTH_IMG_TOPICS=("/azure/depth/image_raw" "/azure/ir/image_raw")
# PCD_TOPICS=("/azure/points2" "/velodyne/velodyne_points")
PCD_TOPICS=()
IMG_TOPICS=()
IMU_TOPICS=("/mcu/mcu_imu")
TEMP_TOPICS=("/mcu/mcu_imu_temp")
TIME_REF_TOPICS=("/mcu_cameras_ts" "/mcu_lidar_ts" "/mcu_s10_ts" )

# Activate virtual environment
source venv/bin/activate;
# Launch roscore in background
roscore &

for BAG in "${@}";
  do
  DATA_DIR="$(basename "$BAG" .bag)"

  # Create a subdirectory for extraction
  rm -rf "$DATA_DIR";
  mkdir "$DATA_DIR";

  # Time reference data extraction
  echo "Time reference data extraction starting..";
  python2 extract.py --output "$DATA_DIR"\
    --type time_ref --path "$BAG" --topics "${TIME_REF_TOPICS[@]}";

  # Image extraction
  echo "Image data extraction starting..";

  if [ ${#IMG_TOPICS[@]} -eq 0 ] ; then
    echo "No image topics provided"
  else
    python2 extract.py --output "$DATA_DIR"\
    --type image --path "$BAG" --topics "${IMG_TOPICS[@]}";
  fi

  # Depth image extraction
  echo "Image data extraction starting..";
  if [ ${#DEPTH_IMG_TOPICS[@]} -eq 0 ] ; then
    echo "No image topics provided"
  else
    python2 extract.py --output "$DATA_DIR"\
      --type depth_img --path "$BAG" --topics "${DEPTH_IMG_TOPICS[@]}";
    # Depth image timestamps alignment
    for topic in "${DEPTH_IMG_TOPICS[@]}";
    do
      python2 align.py --time_ref_file "./$DATA_DIR"/_mcu_cameras_ts/time_ref.csv --target_dir "./$DATA_DIR/${topic//\//_}" --ref_seq 12
    done;
  fi

  # TODO: smartphone timestamps alignment?

  # IMU data extraction
  echo "IMU data extraction starting..";
  python2 extract.py --output "$DATA_DIR"\
    --type imu --path "$BAG" --topics "${IMU_TOPICS[@]}" --temp "${TEMP_TOPICS[@]}";

  # PointCloud extraction
  echo "PointCloud data extraction starting..";
  for topic in "${PCD_TOPICS[@]}"
  do
    PCD_DIR="$DATA_DIR/${topic//\//_}";
    rm -rf "$PCD_DIR";
    mkdir "$PCD_DIR" &&
    rosrun pcl_ros bag_to_pcd "$BAG" "$topic" "$PCD_DIR";
    # Rename <secs.nsecs>.pcd files to match timestamp format
    for file in "$PCD_DIR"/*.*.pcd;
    do
      suf=${file#*.}
      pref=${file%".$suf"}
      mv "$file" "$pref$suf";
    done;
  done;

done;

# Kill roscore running in background
killall roscore