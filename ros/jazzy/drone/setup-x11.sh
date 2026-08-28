#!/bin/bash

XAUTH=/tmp/.docker.xauth

echo "Preparing X11 forwarding for Docker..."

if [ -d "$XAUTH" ]; then
    echo "  -> Found directory at $XAUTH - Removing to fix Docker mount trap..."
    sudo rm -rf "$XAUTH"
fi

if [ ! -f "$XAUTH" ]; then
    touch "$XAUTH"
    chmod 664 "$XAUTH"
fi

if [ -n "$DISPLAY" ]; then
    # clear the file first to ensure no old cookies cause conflicts
    > "$XAUTH" 
    xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - 2>/dev/null
else
    echo " WARNING: DISPLAY variable not set. GUI apps will fail to launch!"
fi

xhost +local:docker > /dev/null
xhost +local:ardupilot > /dev/null

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " X11 Forwarding is READY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. docker compose up -d or docker compose -f docker-compose.yml -f docker-compose-nvidia.yml up -d if you have an NVIDIA GPU"
echo "  2. docker exec -it raptors-drone-dev bash"
echo ""