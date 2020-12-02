import argparse
import rosbag
from src.rosbag_extraction_utils import RosbagUtils

IMG_TYPE='image'
IMU_TYPE='imu'
TIME_REF_TYPE='time_ref'


def main():
    parser = argparse.ArgumentParser(
        description="Extract messages from bag file"
    )
    parser.add_argument(
        "--path",
        type=argparse.FileType(mode='r'),
        required=True
    )
    parser.add_argument(
        "--output",
        required=True
    )
    parser.add_argument(
        '--type',
        choices=[IMG_TYPE, IMU_TYPE, TIME_REF_TYPE],
        help='<Required> Message type for extraction',
        required=True
    )
    parser.add_argument('--topics', nargs='+', help='<Required> List of topics', required=True)
    parser.add_argument('--temp', nargs='+', help='<Optional> IMU temperature topics')

    args = parser.parse_args()
    path = args.path.name
    output = args.output
    topics = args.topics
    bag = rosbag.Bag(path, mode='r')

    # init extractor utils
    utils = RosbagUtils(bag, output)
    if args.type == IMG_TYPE:
        print("Extracting image data..")
        utils.extract_images(topics)
    elif args.type == IMU_TYPE:
        temp_topics = args.temp
        if temp_topics is not None:
            print("Extracting IMU data..")
            utils.extract_imu(topics, temp_topics)
    elif args.type == TIME_REF_TYPE:
        print("Extracting time reference data..")
        utils.extract_time_ref(topics)
    bag.close()


if __name__ == '__main__':
    main()
