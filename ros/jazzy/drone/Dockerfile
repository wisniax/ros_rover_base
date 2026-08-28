ARG RRB_IMAGE_BASE_TAG=latest
FROM docker.io/wisniax/ros-rover-base:${RRB_IMAGE_BASE_TAG}

ENV SSH_PORT=22

# devcontainers ***fix*** by ubuntu devs...
# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN userdel -r ubuntu

RUN echo "root:changeme" | chpasswd

# Temporarly disable the default docker-clean config and tell apt to keep downloaded packages
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    vim \
    software-properties-common \
    tini \
    espeak-ng libespeak-ng-dev 

# X11 and GUI 
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    x11-apps \
    mesa-utils \
    libgl1 \
    libglx-mesa0 \
    libegl1 \
    libgl1-mesa-dri


# Gazebo
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    ros-jazzy-ros-gz-sim

# packages for ArduPilot plugin
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    lsb-release \
    gnupg

# Gazebo repo and 
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
        gz-harmonic \
        libgz-cmake3-dev \
        libgz-sim8-dev

# ArduPilot Gazebo plugin
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev

# Clone ardupilot_gazebo plugin
RUN git clone https://github.com/ArduPilot/ardupilot_gazebo /opt/ardupilot_gazebo \
    && cd /opt/ardupilot_gazebo \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j$(nproc) \
    && make install

# MAVROS
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    ros-jazzy-mavros \
    ros-jazzy-mavros-extras


# Install GeographicLib datasets for MAVROS
RUN wget https://raw.githubusercontent.com/mavlink/mavros/refs/heads/ros2/mavros/scripts/install_geographiclib_datasets.sh \
    && chmod +x install_geographiclib_datasets.sh \
    && ./install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh


# QGroundControl dependencies (Updated for Ubuntu 24.04 Noble)
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    libpulse-mainloop-glib0 \
    libudev1 \
    libdbus-1-3 \
    libfuse2 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    libxcb-cursor-dev \
    libasound2t64 \
    libnss3 \
    gstreamer1.0-gl \
    gstreamer1.0-plugins-bad

# Download and extract QGroundControl
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl-x86_64.AppImage \
        -O /tmp/QGroundControl.AppImage \
    && chmod +x /tmp/QGroundControl.AppImage \
    && cd /tmp && ./QGroundControl.AppImage --appimage-extract \
    && mv /tmp/squashfs-root /opt/QGroundControl \
    && rm /tmp/QGroundControl.AppImage \
    && ln -s /opt/QGroundControl/AppRun /usr/local/bin/qgroundcontrol

# ArduPilot dependencies
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    python3-dev \
    python3-opencv \
    python3-matplotlib \
    python3-lxml \
    libxml2-dev \
    libxslt1-dev

# Required build dependencies for source compilation
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y \
    libgtk-3-dev \
    libsdl2-dev \
    libnotify-dev \
    libxtst-dev \
    libxss-dev \
    libxxf86vm-dev \
    libsm-dev \
    pkg-config \
    build-essential

# Install wxPython
RUN pip3 install --break-system-packages \
    wxPython

# Mavproxy
RUN pip3 install --break-system-packages \
    MAVProxy \
    pymavlink

# Ardupilot and its environment
# Create non-root user
RUN useradd -m -s /bin/bash -G dialout,video ardupilot \
    && echo "ardupilot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Give ardupilot ownership of the QGC
RUN chown -R ardupilot:ardupilot /opt/QGroundControl && \
    chown -h ardupilot:ardupilot /usr/local/bin/qgroundcontrol && \
    chmod +x /usr/local/bin/qgroundcontrol

# Prepare ArduPilot folder
RUN mkdir -p /opt/ardupilot \
    && chown -R ardupilot:ardupilot /opt/ardupilot

# Switch to non-root user to install ArduPilot environment
USER ardupilot
WORKDIR /opt/ardupilot

ENV SKIP_PYTHON2=true
ENV USER=ardupilot

# Clone ArduPilot repository and install prerequisites
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    git clone --recurse-submodules https://github.com/ArduPilot/ardupilot.git . \
    && LATEST_TAG=$(git tag -l "Copter-*" --sort=-v:refname | head -n 1) \
    && git checkout $LATEST_TAG \
    && Tools/environment_install/install-prereqs-ubuntu.sh -y

# Switch to root temporarily to install Python build dependencies
USER root
RUN pip3 install --break-system-packages \
    future \
    empy \
    pexpect

# Switch back to ardupilot user for compilation
USER ardupilot
WORKDIR /opt/ardupilot

# Precompile ArduPilot for SITL
RUN cd /opt/ardupilot \
    && ./waf configure --board sitl \
    && ./waf build --target bin/arducopter

# Switch back to root for the rest of the Dockerfile
USER root

WORKDIR /opt

# Configure Git for root user
RUN git config --global --add safe.directory /opt/ardupilot

WORKDIR /workspace

COPY aliases/ /etc/profile.d/drone_aliases/
RUN echo "# Load drone aliases" >> /etc/bash.bashrc && \
    echo "for f in /etc/profile.d/drone_aliases/*.sh; do source \$f; done" >> /etc/bash.bashrc && \
    echo "source /opt/ros/jazzy/setup.bash" >> /etc/bash.bashrc

# configure sshd
COPY buildfiles/50-sshd-raptors-docker.conf /etc/ssh/sshd_config.d/

# configure bash env with variables and source ros
COPY buildfiles/raptors-drone-bash-env.sh /etc/profile.d/raptors-drone-bash-env.sh
RUN echo "\nBASH_ENV=/etc/profile.d/raptors-drone-bash-env.sh" >> /etc/environment
RUN echo "\nsource /etc/profile.d/raptors-drone-bash-env.sh" >> /etc/bash.bashrc

# Reenable the default docker-clean config
RUN sudo rm -f /etc/apt/apt.conf.d/keep-cache && \
    sudo mv /etc/apt/apt.conf.d/docker-clean.bak /etc/apt/apt.conf.d/docker-clean

# overwrite entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
