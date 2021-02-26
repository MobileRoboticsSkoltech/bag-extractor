FROM ros:melodic-perception
ENTRYPOINT ["./extract.sh"]

# set a directory for the app
WORKDIR .

# copy all the files to the container
COPY . .

RUN chmod +x ./extract.sh

RUN apt-get update -y && apt-get install -y software-properties-common

# install required packages
RUN add-apt-repository -y universe && apt-get update -y && apt-get install -y \
    psmisc \
    python2.7 \
    python-pip \
    ffmpeg

RUN ./setup.sh