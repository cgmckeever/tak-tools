#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

TAK_ALIAS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_ALIAS" | tr -d '\r')
URL=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$URL" | tr -d '\r')
CAPASS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
PASS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')
TAK_COT_PORT=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_COT_PORT" | tr -d '\r')
TAK_CA=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_CA" | tr -d '\r')

## create package
#
source ${TAK_SCRIPT_PATH}/v1/client-data-package.inc.sh