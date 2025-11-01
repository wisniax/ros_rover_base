# Use the official image as a parent image
FROM docker.io/library/ros:jazzy

# Default configuration
ENV ROS_ENABLE_AUTOSTART=0
ENV ROS_BUILD_ON_STARTUP=on-failure
ENV ROS_ENABLE_CAN_BRIDGE=0

# Update the system and Install random stuff
RUN apt update && apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y git gdb nano curl wget python3 python3-pip net-tools \
    apt-utils nano can-utils ssh libpaho-mqttpp-dev libpaho-mqtt-dev less iputils-ping bc rapidjson-dev iproute2

# Random Stuff
ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime

# Disable sudo password auth
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Environment setup
RUN apt update && apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y ros-jazzy-ros2-socketcan libasio-dev libceres-dev ros-jazzy-diagnostic-updater \
    ros-jazzy-diagnostic-updater ros-jazzy-rtcm-msgs ros-jazzy-nmea-msgs ros-jazzy-realtime-tools

COPY ros/jazzy/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
