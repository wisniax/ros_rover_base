#!/bin/bash

get_param() {
    if [ -z "$1" ]; then
        echo "Usage: get_param <param_name>"
        return 1
    fi
    ros2 param get /mavros/param "$1"
}

set_param() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: set_param <param_name> <value>"
        return 1
    fi
    
    local param_name="$1"
    local value="$2"
    local param_type=2 
    local value_field="integer_value: ${value}"

    # If the value contains a decimal point, switch payload to Real/Float (type 3)
    if [[ "$value" == *.* ]]; then
        param_type=3
        value_field="real_value: ${value}"
    fi

    ros2 service call /mavros/param/set mavros_msgs/srv/ParamSetV2 "{param_id: '${param_name}', value: {type: ${param_type}, ${value_field}}}"
}

save_params() {
    echo "Saving parameters to EEPROM..."
    ros2 service call /mavros/param/pull std_srvs/srv/Trigger {}
}