ARG RRB_IMAGE_AUTONOMY_TAG=autonomy-latest
FROM docker.io/wisniax/ros-rover-base:${RRB_IMAGE_AUTONOMY_TAG}

USER root

# Temporarly disable the default docker-clean config and tell apt to keep downloaded packages
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install autonomy-related packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y ros-jazzy-ros-gz ros-jazzy-turtlebot3-gazebo

# Reenable the default docker-clean config
RUN rm -f /etc/apt/apt.conf.d/keep-cache && \
    mv /etc/apt/apt.conf.d/docker-clean.bak /etc/apt/apt.conf.d/docker-clean

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
