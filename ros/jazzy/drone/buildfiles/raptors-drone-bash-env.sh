#!/bin/bash

export GZ_VERSION=${GZ_VERSION:-harmonic}
export GZ_SIM_SYSTEM_PLUGIN_PATH=${GZ_SIM_SYSTEM_PLUGIN_PATH:-/usr/local/lib/ardupilot_gazebo}
export GZ_SIM_RESOURCE_PATH=${GZ_SIM_RESOURCE_PATH:-/opt/ardupilot_gazebo/models:/opt/ardupilot_gazebo/worlds}
export DISPLAY=${DISPLAY:-:0}
export QT_X11_NO_MITSHM=${QT_X11_NO_MITSHM:-1}
export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-xcb}
export XAUTHORITY=${XAUTHORITY:-/tmp/.docker.xauth}
export ARDUPILOT_HOME=${ARDUPILOT_HOME:-/opt/ardupilot}
export FCU_URL=${FCU_URL:-"udp://:14551@"}
export PULSE_SERVER=tcp:127.0.0.1:4800
export PATH=/usr/lib/ccache:/opt/ardupilot/Tools/autotest:$PATH

source /opt/ros/jazzy/setup.bash
if [ -f /workspace/install/setup.bash ]; then
    source /workspace/install/setup.bash
fi