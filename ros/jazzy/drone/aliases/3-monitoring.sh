#!/bin/bash

# Monitoring aliases
alias state='ros2 topic echo /mavros/state'
alias topics='ros2 topic list | grep mavros'
alias pos='ros2 topic echo /mavros/global_position/global'
alias battery='ros2 topic echo /mavros/battery'

# Comprehensive status
status() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "DRONE STATUS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ros2 topic echo /mavros/state --once
    echo ""
    echo "POSITION:"
    ros2 topic echo /mavros/global_position/global --once
    echo ""
    echo "BATTERY:"
    ros2 topic echo /mavros/battery --once
}

check_connection() {
    echo "Checking MAVROS connection..."
    timeout 5 ros2 topic echo /mavros/state --once > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "MAVROS is connected"
    else
        echo "MAVROS is not connected"
        echo "Try running: start_mavros"
    fi
}

nodes() {
    echo "Active ROS2 nodes:"
    ros2 node list
}

preflight() {
    echo "Running preflight checks..."
    echo ""
    echo "1. Checking MAVROS connection..."
    check_connection
    echo ""
    echo "2. Checking GPS..."
    timeout 3 ros2 topic echo /mavros/global_position/global --once
    echo ""
    echo "3. Checking battery..."
    timeout 3 ros2 topic echo /mavros/battery --once
    echo ""
    echo "Preflight check complete"
}