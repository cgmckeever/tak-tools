#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

printf $warning "\n\n------------ Stopping Docker ------------\n"
${DOCKER_COMPOSE} -f ${DOCKER_COMPOSE_YML} down -v
docker volume rm --force tak-server_tak_data

printf $warning "\n\n------------ Prune all unused containers ------------\n"
printf $info "\n\nAnswer [y]es if you want to delete containers.\n"
docker system prune -a

printf $warning "\n\n------------ Remove Docker Service ------------\n"
sudo systemctl disable tak-server-docker
sudo rm -rf /etc/systemd/system/tak-server-docker.service

sudo rm -rf $(readlink -f ${WORK_PATH})
sudo rm -rf ${WORK_PATH}
sudo rm -rf ${CORE_FILES}
sudo rm -rf ~/info.txt
sudo rm -rf ~/logs