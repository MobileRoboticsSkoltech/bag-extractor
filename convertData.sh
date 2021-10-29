#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f $0))
PERSON_DIR=$1
PERSON_DIR=$(echo "$PERSON_DIR" | sed 's:/*$::')

POSES=$PERSON_DIR/*

for POSE in $POSES
do
	./local_extract.sh $POSE
	./toASL.sh $POSE
done
