RRB_IMAGE_NAME := wisniax/ros-rover-base## image name

RRB_IMAGE_TAG_SUFFIX :=## suffix for image (e.g. ...SUFFIX=v2 -> tag: base-v2)
RRB_IMAGE_TAG_SUFFIX := $(if ${RRB_IMAGE_TAG_SUFFIX},-${RRB_IMAGE_TAG_SUFFIX}) 

RRB_IMAGE_BASE_TAG ?= latest${RRB_IMAGE_TAG_SUFFIX}## overriden tag for base
RRB_IMAGE_AUTONOMY_TAG ?= autonomy${RRB_IMAGE_TAG_SUFFIX}## overriden tag for autonomy
RRB_IMAGE_DRONE_TAG ?= drone${RRB_IMAGE_TAG_SUFFIX}## overriden tag for drone
EXTRA_DOCKER_OPTS ?=## extra docker options

.DEFAULT: all

.PHONY: all
all: base autonomy drone
all: ## build all

.PHONY: help
help:
	@echo "Avaliable targets:"
	@sed -En 's/^([a-zA-Z0-9_-]+):.+?##(.+?)$$/\1|\2/p' Makefile | sort -u | column -t -s "|"
	@echo 
	@echo "Env:"
	@sed -En 's/^([a-zA-Z0-9_-]+) *(:=|\?=)(.+?)\s*##(.+?)$$/\1|\4|default: \3/p' Makefile | sort -u | column -t -s "|"

.PHONY: base
base: ## build base image
	@echo -e '\n>> Building ${RRB_IMAGE_NAME}:${RRB_IMAGE_BASE_TAG}'
	docker build ${EXTRA_DOCKER_OPTS} \
	-f ./ros/jazzy/base/Dockerfile \
	-t ${RRB_IMAGE_NAME}:${RRB_IMAGE_BASE_TAG} \
	.

.PHONY: autonomy
autonomy: base
autonomy: ## build autonomy image
	@echo -e '\n>> Building ${RRB_IMAGE_NAME}:${RRB_IMAGE_AUTONOMY_TAG}'
	docker build ${EXTRA_DOCKER_OPTS} \
	--build-arg RRB_IMAGE_BASE_TAG=${RRB_IMAGE_BASE_TAG} \
	-f ./ros/jazzy/autonomy/Dockerfile \
	-t ${RRB_IMAGE_NAME}:${RRB_IMAGE_AUTONOMY_TAG} \
	.

.PHONY: drone
drone: base
drone: ## build drone image
	@echo -e '\n>> Building ${RRB_IMAGE_NAME}:${RRB_IMAGE_DRONE_TAG}'
	docker build ${EXTRA_DOCKER_OPTS} \
	--build-arg RRB_IMAGE_BASE_TAG=${RRB_IMAGE_BASE_TAG} \
	-f ./ros/jazzy/drone/Dockerfile \
	-t ${RRB_IMAGE_NAME}:${RRB_IMAGE_DRONE_TAG} \
	.