#!/bin/bash

printf $warning "\n\nTAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    $DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} restart tak-server
    source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh
fi