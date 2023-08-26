#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

$DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} restart tak-server
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh