FROM docker.io/wisniax/ros-rover-base:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    vim \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# X11 and GUI 
RUN apt-get update && apt-get install -y \
    x11-apps \
    mesa-utils \
    libgl1 \
    libglx-mesa0 \
    libegl1 \
    libgl1-mesa-dri \
    && rm -rf /var/lib/apt/lists/*


# Gazebo
RUN apt-get update && apt-get install -y \
    ros-jazzy-ros-gz-sim \
    && rm -rf /var/lib/apt/lists/*

# Gazebo repo and packages for ArduPilot plugin
RUN apt-get update && apt-get install -y \
    lsb-release \
    gnupg \
    && wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && apt-get update \
    && apt-get install -y \
        gz-harmonic \
        libgz-cmake3-dev \
        libgz-sim8-dev \
    && rm -rf /var/lib/apt/lists/*

# ArduPilot Gazebo plugin
RUN apt-get update && apt-get install -y \
    libopencv-dev \
    libgstreamer1.0-dev \           
    libgstreamer-plugins-base1.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone ardupilot_gazebo plugin
RUN git clone https://github.com/ArduPilot/ardupilot_gazebo /opt/ardupilot_gazebo \
    && cd /opt/ardupilot_gazebo \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j$(nproc) \
    && make install

# MAVROS
RUN apt-get update && apt-get install -y \
    ros-jazzy-mavros \
    ros-jazzy-mavros-extras \
    && rm -rf /var/lib/apt/lists/*


# Install GeographicLib datasets for MAVROS
RUN wget https://raw.githubusercontent.com/mavlink/mavros/refs/heads/ros2/mavros/scripts/install_geographiclib_datasets.sh \
    && chmod +x install_geographiclib_datasets.sh \
    && ./install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# ArduPilot dependencies
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-opencv \
    python3-matplotlib \
    python3-lxml \
    libxml2-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install wxPython for MAVProxy GUI
RUN pip3 install --break-system-packages \
    -f https://extras.wxpython.org/wxPython4/extras/linux/gtk3/ubuntu-24.04 \
    wxPython

# Mavproxy
RUN pip3 install --break-system-packages \
    MAVProxy \
    pymavlink

# Ardupilot and its environment
# Create non-root user
RUN useradd -m -s /bin/bash -G dialout ardupilot \
    && echo "ardupilot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Prepare ArduPilot folder
RUN mkdir -p /opt/ardupilot \
    && chown -R ardupilot:ardupilot /opt/ardupilot

# Switch to non-root user to install ArduPilot environment
USER ardupilot
WORKDIR /opt/ardupilot
ENV USER=ardupilot
ENV SKIP_PYTHON2=true

# Clone ArduPilot repository and install prerequisites
RUN git clone --recurse-submodules https://github.com/ArduPilot/ardupilot.git . \
    && LATEST_TAG=$(git tag -l "Copter-*" --sort=-v:refname | head -n 1) \
    && git checkout $LATEST_TAG \
    && Tools/environment_install/install-prereqs-ubuntu.sh -y

# Add ArduPilot tools to PATH
ENV PATH="/opt/ardupilot/Tools/autotest:${PATH}"
ENV PATH="/usr/lib/ccache:${PATH}"


# Switch back to root for the rest of the Dockerfile
USER root
WORKDIR /opt

# Configure Git for root user
RUN git config --global --add safe.directory /opt/ardupilot

# Install ArduPilot Python build dependencies for root user
RUN pip3 install --break-system-packages \
    future \
    empy \
    pexpect

WORKDIR /workspace

RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

# Set environment variables
ENV ARDUPILOT_HOME=/opt/ardupilot
ENV FCU_URL="udp://:14550@"

# Set display for X11
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

RUN echo '#!/bin/bash\n\
set -e\n\
source /opt/ros/jazzy/setup.bash\n\
export GZ_VERSION=harmonic\n\
export GZ_SIM_SYSTEM_PLUGIN_PATH=/usr/local/lib/ardupilot_gazebo\n\
export GZ_SIM_RESOURCE_PATH=/opt/ardupilot_gazebo/models:/opt/ardupilot_gazebo/worlds\n\
if [ -f /workspace/install/setup.bash ]; then\n\
    source /workspace/install/setup.bash\n\
fi\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]