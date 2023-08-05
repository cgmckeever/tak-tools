#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

${DOCKER_COMPOSE} -f ~/tak-server/docker-compose.yml down
docker volume rm --force tak-server_tak_data

printf $warning "\n\nAnswer [y]es if you want to delete containers.\n"
docker system prune -a

sudo systemctl disable tak-server-docker
sudo rm -rf /etc/systemd/system/tak-server-docker.service

sudo rm -rf ~/tak-server

