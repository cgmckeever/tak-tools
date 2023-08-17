#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

export TAK_ALIAS=$($DOCKER_COMPOSE -f ${WORK_PATH}/docker-compose.yml exec tak-server bash -c "echo \$TAK_ALIAS" | tr -d '\r')
export URL=$($DOCKER_COMPOSE -f ${WORK_PATH}/docker-compose.yml exec tak-server bash -c "echo \$URL" | tr -d '\r')
export CAPASS=$($DOCKER_COMPOSE -f ${WORK_PATH}/docker-compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
export TAK_COT_PORT=$($DOCKER_COMPOSE -f ${WORK_PATH}/docker-compose.yml exec tak-server bash -c "echo \$TAK_COT_PORT" | tr -d '\r')
export TAK_CA=$($DOCKER_COMPOSE -f ${WORK_PATH}/docker-compose.yml exec tak-server bash -c "echo \$TAK_CA" | tr -d '\r')

## create package
#
source ${TAK_SCRIPT_PATH}/v1/autoenroll-data-package.inc.sh