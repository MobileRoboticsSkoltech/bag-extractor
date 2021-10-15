#!/bin/bash
# Copyright 2021 Mobile Robotics Lab. at Skoltech
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

SCRIPT_DIR=$(dirname $(readlink -f $0))
CAM_TRAJ_PATH="CameraTrajectory.txt"
# Import configuration values
source configs/full-bandeja.conf

DATA_DIR_=$1
DATA_DIR=$(echo "$DATA_DIR_" | sed 's:/*$::')
echo "$DATA_DIR_" "$DATA_DIR/"

SMARTPHONE_VIDEO_DIR="smartphone_video_frames"
IMU_DIR="_mcu_imu"

video_files=("$DATA_DIR/$SMARTPHONE_VIDEO_DIR"/*.mp4)
echo "Found video file ${video_files[0]}"
SMARTPHONE_VIDEO_PATH="${video_files[0]}"

# Check if video exists
if [ ! -f "$SMARTPHONE_VIDEO_PATH" ]; then
    >&2 echo "Smartphone video file doesn't exist"
else
    rm -f "$DATA_DIR/$SMARTPHONE_VIDEO_DIR/"*.png
    ffmpeg -i "$SMARTPHONE_VIDEO_PATH" -vsync 0 "$DATA_DIR/$SMARTPHONE_VIDEO_DIR/frame-%d.png"
    python "$SCRIPT_DIR/local_extract.py" --output "$DATA_DIR"\
     --frame_dir "$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --vid "$SMARTPHONE_VIDEO_PATH"
fi

while IFS=, read -r seq timestamp col3; do
  echo "Sequence: $seq | starts with $timestamp"
  SEQUENCE_TIMESTAMPS=("${SEQUENCE_TIMESTAMPS[@]}" "$timestamp")
done <"$DATA_DIR"/_sequences_ts/time_ref.csv

# Split to sequences
if [ "$2" == "--split" ]; then
  echo "Should split the file by sequences"
  if [ ${#SEQUENCE_TIMESTAMPS[@]} -eq 0 ]; then
    echo "No sequence timestamps were found, skipping split"
  else
    ALL_TOPICS=("${DEPTH_IMG_TOPICS[@]}")
    for topic in "${ALL_TOPICS[@]}"; do
      if [ ! -d "$DATA_DIR/${topic//\//_}" ]; then
        echo >&2 "Skipping topic directory which doesn't exist"
      else
        python "$SCRIPT_DIR/split.py" --type file --target_dir "$DATA_DIR/${topic//\//_}" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}"
      fi
    done

    for csv_file in "$DATA_DIR"/"$IMU_DIR"/*.csv; do
      python "$SCRIPT_DIR/split.py" --type csv_t_first --target_dir "$DATA_DIR/$IMU_DIR" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}" \
        --csv "$(basename "$csv_file")"
    done

    python "$SCRIPT_DIR/split.py" --type file --target_dir "$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}"

    for csv_file in "$DATA_DIR"/"$SMARTPHONE_VIDEO_DIR"/*.csv; do
      python "$SCRIPT_DIR/split.py" --type csv_t_last --target_dir "$DATA_DIR/$SMARTPHONE_VIDEO_DIR" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}" \
        --csv "$(basename "$csv_file")"
    done

    python "$SCRIPT_DIR/split.py" --type csv_t_first --target_dir "$DATA_DIR" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}" \
        --csv "$CAM_TRAJ_PATH" --space 1 --time_unit 1000000000
  fi

fi
