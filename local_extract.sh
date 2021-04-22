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

# Import configuration values
source extract.conf
# Activate virtual environment
source venv/bin/activate
source /opt/ros/melodic/setup.bash

DATA_DIR=$1
SMARTPHONE_VIDEO_DIR="smartphone_video_frames"

video_files=("$DATA_DIR$SMARTPHONE_VIDEO_DIR"/*.mp4)
echo "Found video file ${video_files[0]}"
SMARTPHONE_VIDEO_PATH="${video_files[0]}"

# Check if video exists
if [ ! -f "$SMARTPHONE_VIDEO_PATH" ]; then
    >&2 echo "Smartphone video file doesn't exist"
else
    ffmpeg -i "$SMARTPHONE_VIDEO_PATH" -vsync 0 "$DATA_DIR$SMARTPHONE_VIDEO_DIR/frame-%d.png"
    python2 extract.py --output "$DATA_DIR"\
     --type sm_frames --frame_dir "$DATA_DIR$SMARTPHONE_VIDEO_DIR" --vid "$SMARTPHONE_VIDEO_PATH"
fi

while IFS=, read -r seq timestamp col3
do
    echo "Sequence: $seq | starts with $timestamp"
    SEQUENCE_TIMESTAMPS=("${SEQUENCE_TIMESTAMPS[@]}" "$timestamp")
done < "$DATA_DIR"_sequences_ts/time_ref.csv


# Split to sequences
if [ "$2" == "--split" ]; then
  echo "Should split the file by sequences"
  if [ ${#SEQUENCE_TIMESTAMPS[@]} -eq 0 ]; then
    echo "No sequence timestamps were found, skipping split"
  else
    ALL_TOPICS=( "${PCD_TOPICS[@]}" "${IMG_TOPICS[@]}"\
    "${IMU_TOPICS[@]}" "${TEMP_TOPICS[@]}" "${DEPTH_IMG_TOPICS[@]}" )
    for topic in "${ALL_TOPICS[@]}" 
      do
        if [ ! -d "$DATA_DIR${topic//\//_}" ]; then
          >&2 echo "Skipping topic directory which doesn't exist"
        else
          python2 split.py --target_dir "$DATA_DIR${topic//\//_}" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}"
        fi
      done

      python2 split.py --target_dir "$DATA_DIR$SMARTPHONE_VIDEO_DIR" --data_dir "$DATA_DIR" --timestamps "${SEQUENCE_TIMESTAMPS[@]}"

      for cam_info in "${CAM_INFO_TOPICS[@]}"
        do
          if [ ! -d "$DATA_DIR${topic//\//_}" ]; then
            >&2 echo "Skipping topic directory which doesn't exist"
          else
            ind=0
            for seq in  "${SEQUENCE_TIMESTAMPS[@]}"
            do
              rm -rf "$DATA_DIR""seq_$ind/${cam_info//\//_}"
              mkdir "$DATA_DIR""seq_$ind/${cam_info//\//_}" &&
              cp "$DATA_DIR${cam_info//\//_}/camera_info.yaml" "$DATA_DIR""seq_$ind/${cam_info//\//_}/camera_info.yaml"
              ind=$((ind+1))
            done
            rm -rf "$DATA_DIR""seq_$ind/${cam_info//\//_}"
            mkdir "$DATA_DIR""seq_$ind/${cam_info//\//_}" &&
            cp "$DATA_DIR${cam_info//\//_}/camera_info.yaml" "$DATA_DIR""seq_$ind/${cam_info//\//_}/camera_info.yaml"
          fi
        done
  fi
fi