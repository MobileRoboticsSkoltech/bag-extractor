import cv2
import os
from cv_bridge import CvBridge
import pypcd


def make_dir_if_needed(dir_path):
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)


def get_timestamp_filename(timestamp, extension):
    return "%d.%s" % (timestamp.secs * 1e9 + timestamp.nsecs, extension)


class RosbagUtils:
    def __init__(self, bag):
        self.bag = bag

    def extract_images(self, image_topic, output_dir):
        make_dir_if_needed(output_dir)

        bridge = CvBridge()
        count = 0
        for topic, msg, t in self.bag.read_messages(topics=[image_topic]):
            cv_img = bridge.imgmsg_to_cv2(msg, desired_encoding="bgr8")
            filename = get_timestamp_filename(t, "png")
            path = os.path.join(output_dir, filename)
            cv2.imwrite(path, cv_img)
            print("Wrote image %i" % count)

            count += 1

    def extract_point_clouds(self, pc_topic, output_dir):
        make_dir_if_needed(output_dir)

        count = 0
        for topic, msg, t in self.bag.read_messages(topics=[pc_topic]):
            pc = pypcd.PointCloud.from_msg(msg)
            filename = get_timestamp_filename(t, "pcd")
            path = os.path.join(output_dir, filename)
            pc.save(path)
            print("Wrote pcd %i" % count)

            count += 1

