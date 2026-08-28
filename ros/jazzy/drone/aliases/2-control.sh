#!/bin/bash

# Arming
alias arm='ros2 service call /mavros/cmd/arming mavros_msgs/srv/CommandBool "{value: true}"'
alias disarm='ros2 service call /mavros/cmd/arming mavros_msgs/srv/CommandBool "{value: false}"'

# Flight modes
alias guided='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: GUIDED}"'
alias stabilize='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: STABILIZE}"'
alias loiter='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: LOITER}"'
alias rtl='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: RTL}"'
alias auto='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: AUTO}"'
alias althold='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: ALT_HOLD}"'
alias poshold='ros2 service call /mavros/set_mode mavros_msgs/srv/SetMode "{custom_mode: POSHOLD}"'

# Basic maneuvers
alias land='ros2 service call /mavros/cmd/land mavros_msgs/srv/CommandTOL "{}"'

takeoff() {
    if [ -z "$1" ]; then
        echo "Usage: takeoff <altitude_in_meters>"
        echo "Example: takeoff 5"
        return 1
    fi
    ros2 service call /mavros/cmd/takeoff mavros_msgs/srv/CommandTOL "{altitude: $1}"
}

arm_and_takeoff() {
    if [ -z "$1" ]; then
        echo "Usage: arm_and_takeoff <altitude_in_meters>"
        return 1
    fi
    echo "Setting DISARM_DELAY to 0 to prevent auto-disarm..."
    set_param DISARM_DELAY 0
    echo "Arming..."
    ros2 service call /mavros/cmd/arming mavros_msgs/srv/CommandBool "{value: true}"
    echo "Taking off to $1 m..."
    ros2 service call /mavros/cmd/takeoff mavros_msgs/srv/CommandTOL "{altitude: $1}"
}

# Velocity control
vel_linear() {
    local x=${1:-0.0}
    local y=${2:-0.0}
    local z=${3:-0.0}
    ros2 topic pub -r 10 /mavros/setpoint_velocity/cmd_vel geometry_msgs/msg/TwistStamped \
        "{header: {stamp: {sec: 0, nanosec: 0}}, twist: {linear: {x: $x, y: $y, z: $z}, angular: {x: 0.0, y: 0.0, z: 0.0}}}" \
        > /dev/null 2>&1 &
    echo "Publishing velocity: x=$x, y=$y, z=$z (background process)"
}

vel() {
    local lx=${1:-0.0}
    local ly=${2:-0.0}
    local lz=${3:-0.0}
    local ax=${4:-0.0}
    local ay=${5:-0.0}
    local az=${6:-0.0}
    ros2 topic pub -r 10 /mavros/setpoint_velocity/cmd_vel geometry_msgs/msg/TwistStamped \
        "{header: {stamp: {sec: 0, nanosec: 0}}, twist: {linear: {x: $lx, y: $ly, z: $lz}, angular: {x: $ax, y: $ay, z: $az}}}" \
        > /dev/null 2>&1 &
    echo "Publishing velocity: linear=[$lx,$ly,$lz] angular=[$ax,$ay,$az] (background)"
}

vel_stop() {
    pkill -f "setpoint_velocity/cmd_vel"
    echo "Stopped velocity commands"
}

# Directional Movements
forward() {
    local speed=${1:-1.0}
    vel_linear $speed 0 0
    echo "Moving forward at ${speed} m/s"
}

backward() {
    local speed=${1:-1.0}
    vel_linear -$speed 0 0
    echo "Moving backward at ${speed} m/s"
}

left() {
    local speed=${1:-1.0}
    vel_linear 0 $speed 0
    echo "Moving left at ${speed} m/s"
}

right() {
    local speed=${1:-1.0}
    vel_linear 0 -$speed 0
    echo "Moving right at ${speed} m/s"
}

up() {
    local speed=${1:-0.5}
    vel_linear 0 0 $speed
    echo "Moving up at ${speed} m/s"
}

down() {
    local speed=${1:-0.5}
    vel_linear 0 0 -$speed
    echo "Moving down at ${speed} m/s"
}

hover() {
    vel_linear 0 0 0
    echo "Hovering (zero velocity)"
}

# Rotation
yaw_left() {
    local rate=${1:-0.5}
    ros2 topic pub -r 10 /mavros/setpoint_velocity/cmd_vel geometry_msgs/msg/TwistStamped \
        "{header: {stamp: {sec: 0, nanosec: 0}}, twist: {linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: $rate}}}" \
        > /dev/null 2>&1 &
    echo "Rotating left at ${rate} rad/s"
}

yaw_right() {
    local rate=${1:-0.5}
    ros2 topic pub -r 10 /mavros/setpoint_velocity/cmd_vel geometry_msgs/msg/TwistStamped \
        "{header: {stamp: {sec: 0, nanosec: 0}}, twist: {linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: -$rate}}}" \
        > /dev/null 2>&1 &
    echo "Rotating right at ${rate} rad/s"
}

yaw_stop() {
    pkill -f "setpoint_velocity/cmd_vel"
    echo "Stopped yaw rotation"
}

# Time movements
move_timed() {
    local x=${1:-0}
    local y=${2:-0}
    local z=${3:-0}
    local duration=${4:-5}
    
    if [ -z "$4" ]; then
        echo "Usage: move_timed <x> <y> <z> <seconds>"
        echo "Example: move_timed 1 0 0 5"
        return 1
    fi
    
    echo "Moving for ${duration} seconds..."
    vel_linear $x $y $z
    sleep $duration
    vel_stop
}

slow_stop() {
    echo "Gradually stopping..."
    vel_linear 0.5 0 0
    sleep 1
    vel_linear 0.2 0 0
    sleep 1
    vel_linear 0 0 0
    echo "Stopped"
}

# Velocity Monitoring
alias vel_current='ros2 topic echo /mavros/local_position/velocity_local --once'
alias vel_setpoint='ros2 topic echo /mavros/setpoint_velocity/cmd_vel --once'