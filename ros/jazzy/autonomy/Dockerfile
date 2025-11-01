FROM docker.io/wisniax/ros-rover-base:latest

# devcontainers ***fix*** by ubuntu devs...
# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN userdel -r ubuntu

ARG USERNAME='rex'
ARG PASSWORD='changeme'
ARG SSH_PORT=22

# Default configuration
ENV ROS_ENABLE_AUTOSTART=0
ENV ROS_BUILD_ON_STARTUP=on-failure
ENV ROS_ENABLE_CAN_BRIDGE=0

# Install autonomy-related packages
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    ros-jazzy-robot-state-publisher ros-jazzy-xacro ros-jazzy-robot-localization \
    ros-jazzy-mola ros-jazzy-mola-state-estimation ros-jazzy-mola-lidar-odometry \
    ros-jazzy-rtabmap-ros ros-jazzy-ouster-ros \
    zstd wget

# Create user
RUN useradd -m -s /bin/bash ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN usermod -aG sudo ${USERNAME}

# Change ssh port and expose it
RUN sed -i "/^#\?Port/ { s/^#//; s/Port .*/Port ${SSH_PORT}/; }" /etc/ssh/sshd_config

USER ${USERNAME}
# Colorful prompts ah yee
RUN sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /home/${USERNAME}/.bashrc

# Add important stuff to bashrc
RUN echo "\nsource /opt/ros/jazzy/setup.bash\nexport ROS_DOMAIN_ID=0\n" >> /home/${USERNAME}/.bashrc

# Compile mesh navigation and navigation2 stack
RUN mkdir -p /home/${USERNAME}/nav_ws/src/
WORKDIR /home/${USERNAME}/nav_ws/src/
RUN git clone https://github.com/naturerobots/mesh_navigation.git && \
    git clone https://github.com/parsley026/navigation2.git --branch jazzy && \
    vcs import --input mesh_navigation/source_dependencies.yaml && \
    rosdep update && rosdep install --from-paths . --ignore-src -r -y
WORKDIR /home/${USERNAME}/nav_ws/
RUN bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_start_end+ console_direct+ --executor parallel"

# # Get zed-ros-wrapper
# RUN mkdir -p /home/${USERNAME}/zed2_ws/src/
# WORKDIR /home/${USERNAME}/zed2_ws/src/
# RUN git clone https://github.com/stereolabs/zed-ros2-wrapper.git
# WORKDIR /home/${USERNAME}/zed2_ws
# # Setup ZED SDK... propriatery sh***
# RUN wget https://stereolabs.sfo2.cdn.digitaloceanspaces.com/zedsdk/5.1/ZED_SDK_Ubuntu24_cuda12.8_tensorrt10.9_v5.1.0.zstd.run
# RUN chmod +x ZED_SDK_Ubuntu*.zstd.run && ./ZED_SDK_Ubuntu*.zstd.run -- silent skip_cuda && rm ZED_SDK_Ubuntu*.zstd.run
# # Back to compiling the wratpper, ignore errors... I hardly care
# RUN rosdep update && rosdep install --from-paths src --ignore-src -r -y
# RUN bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release --event-handlers console_start_end+ console_direct+ --executor parallel || true"
# RUN echo "\nsource $(pwd)/install/local_setup.bash\n" >> /home/${USERNAME}/.bashrc

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
