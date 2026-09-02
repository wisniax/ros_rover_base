ARG RRB_IMAGE_BASE_TAG=latest
FROM docker.io/wisniax/ros-rover-base:${RRB_IMAGE_BASE_TAG}

# devcontainers ***fix*** by ubuntu devs...
# https://askubuntu.com/questions/1513927/ubuntu-24-04-docker-images-now-includes-user-ubuntu-with-uid-gid-1000
RUN userdel -r ubuntu

ARG USERNAME='rex'
ARG PASSWORD='changeme'

ENV SSH_PORT=22
ENV DEBIAN_FRONTEND=noninteractive 

# Username that will be propagated
ENV RRB_USERNAME=${USERNAME}

# Configure XDG variables
ENV XDG_RUNTIME_DIR=/run/${USERNAME}/xdg

# Default configuration
ENV ROS_ENABLE_AUTOSTART=0
ENV ROS_BUILD_ON_STARTUP=on-failure
ENV ROS_ENABLE_CAN_BRIDGE=0

# Temporarly disable the default docker-clean config and tell apt to keep downloaded packages
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install autonomy-related packages
RUN --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    apt update && \
    apt install -y ros-dev-tools ros-jazzy-aruco-opencv ros-jazzy-aruco-ros \
        ros-jazzy-can-msgs ros-jazzy-cartographer ros-jazzy-cartographer-ros \
        ros-jazzy-depthai-ros ros-jazzy-desktop \
        ros-jazzy-ffmpeg-image-transport ros-jazzy-foxglove-bridge ros-jazzy-fuse-core ros-jazzy-fuse-models \
        ros-jazzy-image-pipeline ros-jazzy-image-transport-plugins ros-jazzy-imu-tools \
        ros-jazzy-laser-filters ros-jazzy-librealsense2 \
        ros-jazzy-mola ros-jazzy-mola-lidar-odometry ros-jazzy-mola-state-estimation ros-jazzy-multisensor-calibration \
        ros-jazzy-ouster-ros \
        ros-jazzy-pcl-ros ros-jazzy-point-cloud-transport \
        ros-jazzy-robot-calibration ros-jazzy-robot-localization ros-jazzy-robot-state-publisher ros-jazzy-rtabmap-ros ros-jazzy-rviz-2d-overlay-plugins \
        ros-jazzy-xacro \
        ros-jazzy-zed-description ros-jazzy-grid-map ros-jazzy-zed-msgs ros-jazzy-zstd-image-transport \
        waypipe openbox xwayland weston

# Create user
RUN useradd -m -s /bin/bash ${USERNAME}
RUN echo "${USERNAME}:${PASSWORD}" | chpasswd
RUN usermod -aG sudo ${USERNAME}

# Setup XDG_RUNTIME_DIR
RUN mkdir -p --mode=700 ${XDG_RUNTIME_DIR} \
    && chown -R ${USERNAME}:${USERNAME} ${XDG_RUNTIME_DIR}

# Add GitHub to system-wide known_hosts so it is trusted across all users
RUN mkdir -p -m 0755 /etc/ssh && \
    echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /etc/ssh/ssh_known_hosts && \
    echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=" >> /etc/ssh/ssh_known_hosts && \
    echo "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=" >> /etc/ssh/ssh_known_hosts

# Force Git system-wide to route all github.com HTTPS URLs through SSH
RUN git config --system url."git@github.com:".insteadOf "https://github.com/"

# Push docker env to docker system
RUN sed -i "5i # add xdg runtime dir \nexport XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} \n" ~/.bashrc

# Add weston to aliases
RUN echo "alias weston_start_desktop=\"weston --xwayland\"" >> ~/.bash_aliases

# Colorful prompts ah yee
RUN sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /home/${USERNAME}/.bashrc

# Add important stuff to bashrc
RUN echo "\nsource /opt/ros/jazzy/setup.bash\nexport ROS_DOMAIN_ID=0\n" >> /home/${USERNAME}/.bashrc

# SETUP mesh navigation and navigation2 stack 
COPY --chown=${USERNAME}:${USERNAME} ros/jazzy/autonomy/buildfiles/nav_ws_repos.yaml /home/${USERNAME}/nav_ws/nav_ws_repos.yaml
COPY --chown=${USERNAME}:${USERNAME} ros/jazzy/autonomy/buildfiles/nav_ws.mk /home/${USERNAME}/nav_ws/nav_ws.mk
RUN --mount=type=ssh \
    --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,id=rrb_nav_ws,target=/home/${USERNAME}/docker_cache/nav_ws,uid=1000,gid=1000,sharing=locked \
    make -C "/home/${USERNAME}/nav_ws" -f "/home/${USERNAME}/nav_ws/nav_ws.mk"
RUN rm /home/${USERNAME}/nav_ws/nav_ws.mk

# SETUP rtabmap_ros
COPY --chown=${USERNAME}:${USERNAME} ros/jazzy/autonomy/buildfiles/rtabmap_repos.yaml /home/${USERNAME}/rtabmap/rtabmap_repos.yaml
COPY --chown=${USERNAME}:${USERNAME} ros/jazzy/autonomy/buildfiles/rtabmap.mk /home/${USERNAME}/rtabmap/rtabmap.mk
RUN --mount=type=ssh \
    --mount=type=cache,id=rrb_cache_apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=rrb_lib_apt,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,id=rrb_rtabmap,target=/home/${USERNAME}/docker_cache/rtabmap,uid=1000,gid=1000,sharing=locked \
    make -C "/home/${USERNAME}/rtabmap" -f "/home/${USERNAME}/rtabmap/rtabmap.mk"
RUN rm /home/${USERNAME}/rtabmap/rtabmap.mk

# Reenable the default docker-clean config
RUN sudo rm -f /etc/apt/apt.conf.d/keep-cache && \
    sudo mv /etc/apt/apt.conf.d/docker-clean.bak /etc/apt/apt.conf.d/docker-clean

# owerwrite entry point
COPY /ros/jazzy/autonomy/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# entrypoint must run as root
USER root

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
