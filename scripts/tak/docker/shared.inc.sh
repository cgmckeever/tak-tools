#!/bin/bash

WORK_PATH=~/tak-server # Base directory; where everything kicks off

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_PATH="${WORK_PATH}/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

CORE_FILES=~/core-files
BACKUPS=~/backups

DOCKER_COMPOSE_YML="${CORE_FILES}/docker-compose.yml"

DOCKER_COMPOSE="docker-compose"
if [[ ! $(command -v docker-compose) ]];then
    DOCKER_COMPOSE="docker compose"
fi