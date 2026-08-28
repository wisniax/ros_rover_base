# Raptors-drone-environment

A Docker development environment for the Raptors Drone Team. It bundles ROS2 (Jazzy), Gazebo (gz sim), ArduPilot (SITL), MAVROS/MAVProxy, QGgroundControl, and helpful shell aliases to run, test and develop drone software in a single container.

## Features
- ROS2 Jazzy environment pre-installed
- Gazebo (gz sim harmonic) with ArduPilot Gazebo plugin
- ArduPilot (SITL) cloned and built inside the image
- MAVROS and MAVProxy installed (with GeographicLib datasets)
- QGroundControl pre-installed and configured to run as a non-root user (`ardupilot`)
- Convenience aliases and helper scripts in the `aliases/` directory
- X11 forwarding support for GUI tools and Gazebo

## Layout

- [docker-compose.yml](docker-compose.yml): compose service and volume configuration (repo root)
- [.devcontainer/](.devcontainer/): Dockerfile(s), build context, and devcontainer configuration
- [setup-x11.sh](setup-x11.sh): prepares X11 forwarding for GUI apps
- [aliases/](aliases/): convenience scripts and command aliases used in the container
- [workspace/src](workspace/src): host-mounted ROS2 workspace for your packages
- [docker-compose.yml](docker-compose.yml): compose service and volume configuration with Intel/AMD GPU, this is the default
- [docker-compose-nvidia.yml](docker-compose-nvidia.yml): compose override for NVIDIA GPU passthrough via CDI

## Quickstart

1. Prepare X11 forwarding on the host:

```bash
cd .devcontainer/
sudo bash ./setup-x11.sh
```

2. Build and start the environment:
**Intel/AMD GPU (default):**
```bash
docker compose build
docker compose up -d
```

**NVIDIA dedicated GPU:**
```bash
docker compose build
docker compose -f docker-compose.yml -f docker-compose-nvidia.yml up -d
```

3. Enter the running container shell:

```bash
docker exec -it raptors-drone-dev bash
```

Run `help` or `h` inside the container to list provided helper aliases.

## Verifying Installation
Once inside the container, test the setup with:
```bash
start_gazebo
start_ardupilot
start_qgc
start_mavros
status
# Run these command on separate terminals
```

## Common commands (aliases)

- `start_ardupilot`: run ArduPilot SITL with Gazebo
- `start_gazebo`: start Gazebo (gz-sim)
- `start_mavros`: start the MAVROS node
- `arm` / `disarm`: arm/disarm via MAVROS
- `takeoff <alt>` / `land`: basic flight commands
- `arm_and_takeoff <alt>`: arm and takeoff in one step
- `goto <lat> <lon> [alt]`: send a waypoint
- `record [name]` / `playback <name>`: ros2 bag helpers
- `build` / `rebuild` — `colcon` helpers for building the ROS2 workspace

See the `.devcontainer/aliases/` directory for the full command reference.

## Development workflow

Mount your project into `workspace/src` on the host and build inside the container:

```bash
ws
build
```

Use `rebuild` to clean, build, and source the workspace.

## Troubleshooting

### X11 forwarding issues
If GUI applications fail to open:
```bash
# Remove old auth file and re-run setup
sudo rm -f /tmp/.docker.xauth
sudo bash setup-x11.sh
```

### Gazebo fails to start
If Gazebo fails to open or shows display errors, the QT platform may need to be set manually:
```bash
export QT_QPA_PLATFORM=xcb
start_gazebo
```

### Auto-disarm before takeoff
If the drone disarms itself before you can take off, use the combined command:
```bash
arm_and_takeoff <altitude>
```
This sets `DISARM_DELAY` to 0 before arming, eliminating the race condition.

### Pre-arm checks failing in simulation
If the drone refuses to arm due to pre-arm checks:
```bash
disable_safety_checks
arm_and_takeoff <altitude>
```
To restore safety checks after testing:
```bash
reenable_safety_checks
```

### NVIDIA GPU passthrough issues

If Gazebo or GPU acceleration fails to work with the NVIDIA compose override:

1. Check your Docker version supports CDI (Docker 25+):
```bash
docker --version
```

2. Check CDI devices are available on your host:
```bash
nvidia-ctk cdi list
```

3. If CDI is not supported, use the legacy method in
   `docker-compose-nvidia.yml`:
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu, graphics, display]
```

