import argparse
import rosbag
from src.rosbag_extraction_utils import RosbagUtils


def main():
    parser = argparse.ArgumentParser(
        description="Extract messages from bag file",
        usage=""
    )
    parser.add_argument("--path", type=argparse.FileType(mode='r'), required=True)
    args = parser.parse_args()
    bag = rosbag.Bag(args.path, 'r')
    utils = RosbagUtils(bag)

    # Example usage with test file
    # TODO: move to arguments
    utils.extract_images("/basler/pylon_camera_node0/image_raw", "./images0")
    utils.extract_point_clouds("/velodyne/velodyne_points", "./pc1")

    bag.close()


if __name__ == '__main__':
    main()
