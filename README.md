# Ros bag extractor

Extracts files from .bag files using ros nodes and rosbag python code API. 

Note: 
- [Installation of ROS melodic](http://wiki.ros.org/melodic/Installation) **is required**!
- Requires [ffmpeg](https://ffmpeg.org/) for smartphone video frames extraction


## Usage

**Important**: if you haven't edited your ```~/.bashrc``` for automatic environment 
variable setup as suggested in [ROS installation instructions 1.5](http://wiki.ros.org/melodic/Installation)
you need to run ```source /opt/ros/melodic/setup.bash``` in your current shell first.

------

On the **first usage**, run ```./setup.sh``` to create virtual environment and install requirements.

1. Setup **topic names** for extraction in ```./extract.conf``` file
2. **Run** ```./extract.sh <PATH_TO_BAG> (optional)<PATH_TO_VIDEO>``` with **path to your .bag file** 
    and **path to smartphone video** from OpenCamera Sensors as arguments
     *(note: directory with meta information about video, e.g. ```20210119_233624```, should be in the same path as video)*.
3. **Data is saved** to the subdirectories of ```./<YOUR_BAG_NAME>``` directories (subdirectory name = topic name with ```/``` replaced with ```_```):
    - ```{camera_topic_name}``` - images from camera with timestamps as filenames in ```jpeg``` format
    - ```{depth_camera_topic_name}``` - depth images with timestamps as filenames in ```tiff``` format 
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
    - ```_s10_video_frame``` - extracted smartphone video frames with timestamps as filename

## Samsung dataset timestamps alignment

Additionally, the tool **aligns timestamps** of the extracted data.
- Uses ```time reference``` topic to get time from another source, 
and writes transformation meta information to ```_transformation_metainf.csv``` file in the image directory.

Currently alignment is **implemented for**:
- *depth images*
- *smartphone images*

## Troubleshooting

- If you get this error:
```venv/bin/activate: line 57: PS1: unbound variable```, you should update ```virtualenv``` version, see [this stackoverflow answer](https://stackoverflow.com/a/48327176) for more info.
