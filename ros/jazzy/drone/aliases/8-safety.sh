#!/bin/bash

EMERGENCY_STOP() {
    echo "!!! EMERGENCY STOP TRIGGERED - DISARMING MOTORS NOW !!!"
    timeout 2 ros2 service call /mavros/cmd/arming mavros_msgs/srv/CommandBool "{value: False}"
    echo "Terminating active setpoint streaming nodes..."
    pkill -9 -f "setpoint" 2>/dev/null   
    echo "Kill sequence complete."
}
alias STOP='EMERGENCY_STOP'

disable_safety_checks() {
    echo "WARNING: Disabling pre-arm and safety checks..."
    set_param ARMING_CHECK 0
    set_param DISARM_DELAY 0
    echo "Safety checks disabled! Verifying status:"
    get_param ARMING_CHECK
}

reenable_safety_checks() {
    echo "Enabling safety checks..."
    set_param ARMING_CHECK 1
    set_param DISARM_DELAY 10
    echo "Safety checks re-enabled!"
}

set_geofence() {
    local radius=${1:-100.0}
    if [[ ! "$radius" == *.* ]]; then
        radius="${radius}.0"
    fi
    echo "Setting geofence radius to ${radius}m..."
    set_param FENCE_RADIUS $radius
    echo "Enabling geofence action (RTL on breach)..."
    set_param FENCE_ACTION 1 
    echo "Geofence configured and enabled successfully."
}

disable_geofence() {
    echo "Disabling geofence system..."
    set_param FENCE_ACTION 0
    echo "Geofence disabled."
}