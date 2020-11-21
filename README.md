# Ros bag extractor

Extracts files from .bag files using ros nodes and rosbag python code API. 

Installation of ROS **is required**!

## Usage

1. On the **first usage**, run ```./setup.sh``` to create virtual environment and install requirements
2. Run ```./extract.sh <PATH_TO_BAG>``` with **path to your .bag file** as an argument
    - Make sure topics for all message types in ```./extract.sh``` match your topics (you can update them for your needs)
3. **Data is saved** to the subdirectories of ```./<your_bag_name>``` directory:
    - ```camera<i>``` - images from camera with timestamps as filenames
    - ```pcd<i>```
    - ```imu<i>```