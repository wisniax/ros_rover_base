#!/bin/bash
# Core environment variables and configuration

export ARDUPILOT_HOME=${ARDUPILOT_HOME:-/opt/ardupilot}
export FCU_URL=${FCU_URL:-udp://:14551@}
export GZ_VERSION=harmonic
export GZ_SIM_SYSTEM_PLUGIN_PATH=/usr/local/lib/ardupilot_gazebo
export GZ_SIM_RESOURCE_PATH=/opt/ardupilot_gazebo/models:/opt/ardupilot_gazebo/worlds

# Workspace shortcuts
alias ws='cd /workspace'
alias src='source /workspace/install/setup.bash'