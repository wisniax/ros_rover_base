#!/bin/bash

start_ardupilot() {
    echo "Starting ArduPilot SITL..."
    cd $ARDUPILOT_HOME/ArduCopter
    sim_vehicle.py -v ArduCopter -f gazebo-iris --model JSON --map --console \
        --out=udp:127.0.0.1:14550 \
        --out=udp:127.0.0.1:14551 \
        --no-rebuild
}

start_gazebo() {
    echo "Starting Gazebo..."
    gz sim -v4 -r iris_runway.sdf &
}

start_mavros() {
    echo "Starting MAVROS..."
    ros2 run mavros mavros_node --ros-args \
        -p fcu_url:=$FCU_URL \
        -p target_system_id:=1 \
        -p target_component_id:=1
}

start_qgc() {
    # Check if DISPLAY is actually set before trying to launch
    if [ -z "$DISPLAY" ]; then
        echo "Error: DISPLAY variable is not set. GUI will not launch."
        return 1
    fi

    # Give the 'video' group access to the socket (Safer than 777)
    chown :video /tmp/.X11-unix/X0 2>/dev/null
    chmod 660 /tmp/.X11-unix/X0 2>/dev/null
    
    echo "Launching QGC on $DISPLAY..."
    su - ardupilot -c "export DISPLAY=$DISPLAY; qgroundcontrol --nowarn-root" > /dev/null 2>&1 &
}

stop_gazebo() { pkill -f "gz sim"; }
stop_ardupilot() { pkill -f "sim_vehicle"; pkill -f "mavproxy"; }
stop_mavros() { pkill -f "mavros_node"; }
stop_qgc() { pkill -f "qgroundcontrol"; }

stop_all() {
    pkill -f "gz sim"
    pkill -f "sim_vehicle"
    pkill -f "mavproxy"
    pkill -f "mavros_node"
    pkill -f "QGroundControl"
    echo "All components stopped."
}

# Start only MAVROS 
start_hardware() {
    echo "Starting MAVROS for hardware connection..."
    echo "Make sure your flight controller is connected!"
    
    # For hardware, typically use serial connection
    local hw_fcu_url=${1:-/dev/ttyACM0:57600}
    
    ros2 run mavros mavros_node --ros-args \
        -p fcu_url:=$hw_fcu_url \
        -p target_system_id:=1 \
        -p target_component_id:=1
}

# Minimal start (MAVROS only, for testing)
start_minimal() {
    echo "Starting minimal setup (MAVROS only)..."
    start_mavros
}

# Restart specific component
restart_mavros() {
    echo "Restarting MAVROS..."
    stop_mavros
    sleep 2
    start_mavros
}

restart_gazebo() {
    echo "Restarting Gazebo..."
    stop_gazebo
    sleep 2
    start_gazebo
}

restart_ardupilot() {
    echo "Restarting ArduPilot..."
    stop_ardupilot
    sleep 2
    start_ardupilot
}