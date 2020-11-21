#!/bin/bash
set -xuevo pipefail


# Launch roscore in background
roscore &

for BAG in "${@}";
  do
  DATA_DIR="$(basename $BAG .bag)"
  IMG_TOPICS=("/basler/pylon_camera_node0/image_raw" "/basler/pylon_camera_node1/image_raw")
  PCD_TOPICS=("/azure/points2" "/velodyne/velodyne_points")
  IMU_TOPICS=("/mcu/mcu_imu")
  TEMP_TOPICS=("/mcu/mcu_imu_temp")

  # Activate virtual environment
  source venv/bin/activate;

  # Create a subdirectory for extraction
  rm -rf "$DATA_DIR";
  mkdir "$DATA_DIR";

  # Image extraction
  python2 extract.py --output "$DATA_DIR"\
    --type image --path "$BAG" --topics "${IMG_TOPICS[@]}";

  # IMU data extraction
  python2 extract.py --output "$DATA_DIR"\
    --type imu --path "$BAG" --topics "${IMU_TOPICS[@]}" --temp "${TEMP_TOPICS[@]}";

  # PointCloud extraction
  for i in 0 1
  do
    topic="${PCD_TOPICS[$i]}";
    PCD_DIR="$DATA_DIR/pcd$i";
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