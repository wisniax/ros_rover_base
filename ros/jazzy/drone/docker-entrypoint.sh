#! /bin/bash

# This script will be called by the docker container when it starts
# and will start the REX ROS2 stuff

# Stop script on errors
set -e

# Most important thing: logo ;)
echo "--------------------------------------------------------------------"
echo 'ooooooooo.         .o.       ooooooooo.   ooooooooooooo   .oooooo.   ooooooooo.    .oooooo..o  '
echo '`888   `Y88.      .888.      `888   `Y88. 8`   888   `8  d8P`  `Y8b  `888   `Y88. d8P`    `Y8  '
echo ' 888   .d88`     .8"888.      888   .d88`      888      888      888  888   .d88` Y88bo.       '
echo ' 888ooo88P`     .8` `888.     888ooo88P`       888      888      888  888ooo88P`   `"Y8888o.   '
echo ' 888`88b.      .88ooo8888.    888              888      888      888  888`88b.        `"Y88br  '
echo ' 888  `88b.   .8`     `888.   888              888      `88b    d88`  888  `88b.  oo     .d8P  '
echo 'o888o  o888o o88o     o8888o o888o            o888o      `Y8bood8P`  o888o  o888o 8""88888P`   '

echo "--------------------------------------------------------------------"
echo "Wakey wakey, eggs and bakey! Hello on rex startup!"
echo "--------------------------------------------------------------------"

echo "Loaded configuration:"
echo " - SSH_PORT:  ${SSH_PORT}"

echo "--------------------------------------------------------------------"

echo -e "Port ${SSH_PORT}\n" > /etc/ssh/sshd_config.d/90-dockerenv-ssh-port.conf

if service ssh start; then
    echo "To connect to the container, use ssh rex@localhost -p ${SSH_PORT}"
else
    echo "SSH service failed to start"
fi

echo "--------------------------------------------------------------------"

# Keep container alive forever
echo "Well... This container is somewhat jobless so... Ah anyway."
sleep infinity