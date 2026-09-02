WORKDIR ?= /home/${USERNAME}/rtabmap
CACHEDIR ?= /home/${USERNAME}/docker_cache/rtabmap

.DEFAULT_GOAL := cache_build

restore_cache:
	@echo ">> Restoring cached rtabmap..."
	rsync -a "${CACHEDIR}/" "${WORKDIR}/"

prepare: restore_cache
	@echo ">> Initializing rtabmap..."
	[ -d ${WORKDIR}/src ] || mkdir -p ${WORKDIR}/src
	vcs import --input ${WORKDIR}/rtabmap_repos.yaml ${WORKDIR}/src

build: prepare
	@echo ">> UWU"
	rosdep update
	rosdep install --from-paths ${WORKDIR}/src --ignore-src -r -y
	. /opt/ros/jazzy/setup.sh \
	&& colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DWITH_OPENCL=ON -DWITH_TORCH=OFF \
		--event-handlers console_start_end+ console_direct+ --executor parallel

cache_build: build
	@echo ">> Caching rtabmap..."
	rsync -a "${WORKDIR}/" "${CACHEDIR}/" 