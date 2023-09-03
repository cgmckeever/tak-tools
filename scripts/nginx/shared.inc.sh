#!/bin/bash

WORK_PATH=~/nginx # Base directory; where everything kicks off

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
TOOLS_PATH=$(dirname $(dirname $SCRIPT_PATH))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

CORE_FILES=~/core-files

DOCKER_SERVICE="tak-docs"
DOCKER_COMPOSE_YML="${CORE_FILES}/${DOCKER_SERVICE}-docker-compose.yml"

DOCKER_COMPOSE="docker-compose"
if [[ ! $(command -v docker-compose) ]];then
    DOCKER_COMPOSE="docker compose"
fi