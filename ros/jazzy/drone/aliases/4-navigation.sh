#!/bin/bash

goto() {
    local lat=${1}
    local lon=${2}
    local alt=${3:-10}
    
    if [ -z "$lat" ] || [ -z "$lon" ]; then
        echo "Usage: goto <latitude> <longitude> [altitude]"
        echo "Example: goto 47.3977 8.5456 20"
        return 1
    fi
    
    ros2 service call /mavros/mission/push mavros_msgs/srv/WaypointPush \
        "{waypoints: [{frame: 3, command: 16, is_current: true, autocontinue: true, \
        param1: 0, param2: 0, param3: 0, param4: 0, \
        x_lat: $lat, y_long: $lon, z_alt: $alt}]}"
}

clear_mission() {
    ros2 service call /mavros/mission/clear mavros_msgs/srv/WaypointClear
    echo "Mission cleared"
}