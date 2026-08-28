#!/bin/bash

alias build='cd /workspace && colcon build'

rebuild() {
    cd /workspace
    colcon build --symlink-install
    source install/setup.bash
    echo "Workspace rebuilt and sourced"
}

clean_build() {
    cd /workspace
    rm -rf build/ install/ log/
    colcon build
    source install/setup.bash
    echo "Clean build complete"
}

new_package() {
    if [ -z "$1" ]; then
        echo "Usage: new_package <package_name>"
        return 1
    fi
    cd /workspace/src
    ros2 pkg create --build-type ament_python $1
    echo "Package '$1' created in /workspace/src/"
}