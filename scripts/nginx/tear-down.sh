#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

printf $warning "\n\n------------ Stopping Docker ------------\n"
${DOCKER_COMPOSE} -f ${DOCKER_COMPOSE_YML} down -v

printf $warning "\n\n------------ Prune all unused containers ------------\n"
printf $info "\n\nAnswer [y]es if you want to delete containers.\n"
docker system prune -a

printf $warning "\n\n------------ Remove Docker Service ------------\n"
sudo systemctl disable ${DOCKER_SERVICE}-docker
sudo rm -rf /etc/systemd/system/${DOCKER_SERVICE}-docker.service

sudo rm -rf ${WORK_PATH}
sudo rm -rf ${CORE_FILES}/${DOCKER_SERVICE}*
sudo rm -rf ${CORE_FILES}/.${DOCKER_SERVICE}-env
