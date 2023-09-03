#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

$DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} restart ${DOCKER_SERVICE}