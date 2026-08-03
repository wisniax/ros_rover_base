# syntax=docker/dockerfile:1
# Use the official image as a parent image
FROM docker.io/library/ros:jazzy

# Default configuration
ENV ROS_ENABLE_AUTOSTART=0
ENV ROS_BUILD_ON_STARTUP=on-failure
ENV ROS_ENABLE_CAN_BRIDGE=0

# Temporarly disable the default docker-clean config and tell apt to keep downloaded packages
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install random stuff
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y git gdb nano curl wget python3 python3-pip net-tools \
        apt-utils vim can-utils ssh libpaho-mqttpp-dev libpaho-mqtt-dev less \
        iputils-ping bc rapidjson-dev iproute2 zstd wget rsync make

# Random Stuff
ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime

# Disable sudo password auth
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Environment setup
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y ros-jazzy-ros2-socketcan libasio-dev libceres-dev ros-jazzy-diagnostic-updater \
        ros-jazzy-diagnostic-updater ros-jazzy-rtcm-msgs ros-jazzy-nmea-msgs ros-jazzy-realtime-tools

COPY ros/jazzy/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Reenable the default docker-clean config
RUN rm -f /etc/apt/apt.conf.d/keep-cache && \
    mv /etc/apt/apt.conf.d/docker-clean.bak /etc/apt/apt.conf.d/docker-clean

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
