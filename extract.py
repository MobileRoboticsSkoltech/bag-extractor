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

import argparse
import rosbag
from src.rosbag_extraction_utils import RosbagUtils
from src.sm_utils import extract_frame_data

IMG_TYPE = 'image'
IMU_TYPE = 'imu'
TIME_REF_TYPE = 'time_ref'
DEPTH_IMG_TYPE = 'depth_img'
CAMERA_INFO_TYPE = 'cam_info'
SM_TYPE = 'sm_frames'


def main():
    parser = argparse.ArgumentParser(
        description="Extract messages from bag file"
    )
    parser.add_argument(
        "--path",
        type=argparse.FileType(mode='r'),
        required=False
    )
    parser.add_argument(
        "--output",
        required=True
    )
    parser.add_argument(
        '--type',
        choices=[IMG_TYPE, IMU_TYPE, TIME_REF_TYPE,
                 DEPTH_IMG_TYPE, CAMERA_INFO_TYPE, SM_TYPE],
        help='<Required> Message type for extraction',
        required=True
    )
    parser.add_argument('--topics', nargs='+',
                        help='<Optional> List of topics')
    parser.add_argument('--temp', nargs='+',
                        help='<Optional> IMU temperature topics')
    parser.add_argument(
        '--frame_dir', help='<Optional> Smartphone frames directory')
    parser.add_argument('--vid', help='<Optional> Smartphone video path')

    args = parser.parse_args()

    if args.type == SM_TYPE:
        # TODO: args assertion for dir and vid
        print("Extracting smartphone video frame data..")
        extract_frame_data(args.frame_dir, args.vid)
    else:
        path = args.path.name
        output = args.output
        topics = args.topics
        bag = rosbag.Bag(path, mode='r')

        # init extractor utils
        utils = RosbagUtils(bag, output)
        if args.type == IMG_TYPE:
            print("Extracting image data..")
            utils.extract_images(topics)
        elif args.type == DEPTH_IMG_TYPE:
            print("Extracting depth image data..")
            utils.extract_images(topics, use_depth=True)
        elif args.type == IMU_TYPE:
            temp_topics = args.temp
            if temp_topics is not None:
                print("Extracting IMU data..")
                utils.extract_imu(topics, temp_topics)
        elif args.type == TIME_REF_TYPE:
            print("Extracting time reference data..")
            utils.extract_time_ref(topics)
        elif args.type == CAMERA_INFO_TYPE:
            print("Extracting camera intrinsic data..")
            utils.extract_camera_info(topics)

        bag.close()


if __name__ == '__main__':
    main()
