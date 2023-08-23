#!/bin/bash

printf $warning "TAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    $DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} restart tak-server
fi