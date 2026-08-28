#!/bin/bash

record() {
    local filename=${1:-drone_flight_$(date +%Y%m%d_%H%M%S)}
    echo "Recording to: /workspace/bags/$filename"
    mkdir -p /workspace/bags
    ros2 bag record -o /workspace/bags/$filename \
        /mavros/state \
        /mavros/global_position/global \
        /mavros/local_position/pose \
        /mavros/battery \
        /mavros/imu/data
}

playback() {
    if [ -z "$1" ]; then
        echo "Available recordings:"
        ls -lh /workspace/bags/ 2>/dev/null || echo "No recordings found"
        echo ""
        echo "Usage: playback <bag_name>"
        return 1
    fi
    ros2 bag play /workspace/bags/$1
}

list_bags() {
    echo "Available bag files:"
    ls -lh /workspace/bags/ 2>/dev/null || echo "No recordings found"
}