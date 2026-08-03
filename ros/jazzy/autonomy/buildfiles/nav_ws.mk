WORKDIR ?= /home/${USERNAME}/nav_ws
CACHEDIR ?= /home/${USERNAME}/docker_cache/nav_ws

.DEFAULT_GOAL := cache_build

restore_cache:
	@echo ">> Restoring cached nav_ws..."
	rsync -a "${CACHEDIR}/" "${WORKDIR}/"

prepare: restore_cache
	@echo ">> Initializing nav_ws..."
	[ -d ${WORKDIR}/src ] || mkdir -p ${WORKDIR}/src
	vcs import --input ${WORKDIR}/nav_ws_repos.yaml ${WORKDIR}/src
	vcs import --input ${WORKDIR}/src/mesh_navigation/source_dependencies.yaml --shallow ${WORKDIR}/src

build: prepare
	@echo ">> Building nav_ws..."
	rosdep update
	rosdep install --from-paths ${WORKDIR}/src --ignore-src -r -y
	. /opt/ros/jazzy/setup.sh \
	&& colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release \
		--event-handlers console_start_end+ console_direct+ --executor parallel

cache_build: build
	@echo ">> Caching nav_ws..."
	rsync -a "${WORKDIR}/" "${CACHEDIR}/" 