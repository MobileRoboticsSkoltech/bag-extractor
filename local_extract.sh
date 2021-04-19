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

EXTRACTED_DATA_DIR=$1
SMARTPHONE_VIDEO_DIR="smartphone_video_frames"

video_files=("$EXTRACTED_DATA_DIR/$SMARTPHONE_VIDEO_DIR"/*.mp4)
echo "Found video file ${video_files[0]}"
SMARTPHONE_VIDEO_PATH="${video_files[0]}"

# Check if video exists
if [ ! -f "$SMARTPHONE_VIDEO_PATH" ]; then
    >&2 echo "Smartphone video file doesn't exist"
else
    ffmpeg -i "$SMARTPHONE_VIDEO_PATH" -vsync 0 "./$EXTRACTED_DATA_DIR/$SMARTPHONE_VIDEO_DIR/frame-%d.png"
    python2 extract.py --output "$DATA_DIR"\
     --type sm_frames --frame_dir "$EXTRACTED_DATA_DIR$SMARTPHONE_VIDEO_DIR" --vid "$SMARTPHONE_VIDEO_PATH"
fi