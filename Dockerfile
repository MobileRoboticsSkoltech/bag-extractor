FROM ros:melodic-perception
ENTRYPOINT ["./extract.sh"]

# set a directory for the app
WORKDIR .

# copy all the files to the container
COPY . .

RUN sudo chmod +x ./extract.sh
RUN sudo apt-get update -y
RUN sudo apt-get install -y software-properties-common
RUN sudo add-apt-repository -y universe

RUN sudo apt-get update -y
RUN sudo apt-get install -y python2.7
RUN sudo apt-get install -y python-pip

# install ffmpeg
RUN sudo apt-get install -y ffmpeg

RUN ./setup.sh