ARG RRB_IMAGE_SIMULATION_TAG=simulation
FROM docker.io/wisniax/ros-rover-base:${RRB_IMAGE_SIMULATION_TAG}

USER root

# Temporarly disable the default docker-clean config and tell apt to keep downloaded packages
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Install ROCm repo
## Add ROCm key
RUN mkdir --parents --mode=0755 /etc/apt/keyrings
RUN wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

## Add repo and pin it
COPY --chown=root:root ros/jazzy/simulation-rocm/buildfiles/rocm.list /etc/apt/sources.list.d/rocm.list
COPY --chown=root:root ros/jazzy/simulation-rocm/buildfiles/rocm-pin-600 /etc/apt/preferences.d/rocm-pin-600

# Install autonomy-related packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y rocm-hip-sdk rocm-hip-libraries rocm-ml-sdk rocm-developer-tools \
        composablekernel mivisionx hipify-clang rocdecode rpp rocjpeg rocal rocal-dev

# Reenable the default docker-clean config
RUN rm -f /etc/apt/apt.conf.d/keep-cache && \
    mv /etc/apt/apt.conf.d/docker-clean.bak /etc/apt/apt.conf.d/docker-clean

USER ${RRB_USERNAME}

CMD [ "/usr/local/bin/docker-entrypoint.sh" ]
