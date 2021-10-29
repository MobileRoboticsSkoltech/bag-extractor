#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
DATA_DIR=$1
DATA_DIR=$(echo "$DATA_DIR" | sed 's:/*$::')
DATA="$DATA_DIR/smartphone_video_frames"

mkdir -p "$DATA/cam0/data"
mkdir "$DATA/imu0"

mv $DATA/*.png "$DATA/cam0/data"

TIMESTAMPS=($DATA/*timestamps.csv)
GYRO=($DATA/*gyro.csv)
ACCEL=($DATA/*accel.csv)

if [ ! -f "${TIMESTAMPS[0]}" ]; then
    >&2 echo "No timestamps!"
fi

if [ ! -f "${GYRO[0]}" ]; then
    >&2 echo "No gyro!"
fi

if [ ! -f "${ACCEL[0]}" ]; then
    python3 "$SCRIPT_DIR/process_csv.py" "$DATA" "$TIMESTAMPS" "$GYRO"
    >&2 echo "No accel!"
else
    python3 "$SCRIPT_DIR/process_csv.py" "$DATA" "$TIMESTAMPS" "$GYRO" "$ACCEL"
fi

mv $DATA/timestamps.csv $DATA/cam0/data.csv
mv $DATA/gyro_accel.csv $DATA/imu0/data.csv
