#!/bin/bash

WORK_PATH=~/tak-server # Base directory; where everything kicks off

TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_PATH="${WORK_PATH}/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

DOCKER_CERT_PATH="/opt/tak/certs"

DOCKER_COMPOSE="docker-compose"
if [[ ! $(command -v docker-compose) ]];then
    DOCKER_COMPOSE="docker compose"
fi