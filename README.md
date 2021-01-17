# Ros bag extractor

Extracts files from .bag files using ros nodes and rosbag python code API. 

Note: [Installation of ROS melodic](http://wiki.ros.org/melodic/Installation) **is required**!


## Usage

**Important**: if you haven't edited your ```~/.bashrc``` for automatic environment 
variable setup as suggested in [ROS installation instructions 1.5](http://wiki.ros.org/melodic/Installation)
you need to run ```source /opt/ros/melodic/setup.bash``` in your current shell first.

------

On the **first usage**, run ```./setup.sh``` to create virtual environment and install requirements.

1. **Run** ```./extract.sh <PATH_TO_BAG> .. <PATH_TO_BAG>``` with **paths to your .bag files** as arguments
    - Make sure topics for all message types in ```./extract.sh``` match your topics (you can update them for your needs)
3. **Data is saved** to the subdirectories of ```./<YOUR_BAG_NAME>``` directories (subdirectory name = topic name with ```/``` replaced with ```_```):
    - ```{camera_topic_name}``` - images from camera with timestamps as filenames
    - ```{poincloud_topic_name}``` - point cloud files with timestamps as filename
    - ```{time_ref_topic_name}``` - time reference files, format:
        ```
        <sequence_number, timestamp, time_ref>
        ```
    - ```{imu_topic_name}``` - ```csv``` files, format:
        ```
        <timestamp, ox, oy, oz, ax, ay, az, temperature>
        ```
        *where ox, oy, oz - angular velocity; ax, ay, az - linear acceleration*


## Troubleshooting

- If you get this error:
```venv/bin/activate: line 57: PS1: unbound variable```, you should update ```virtualenv``` version, see [this stackoverflow answer](https://stackoverflow.com/a/48327176) for more info.
