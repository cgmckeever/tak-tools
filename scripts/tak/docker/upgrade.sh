#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

printf $warning "\n\nAvailable Releases: \n\n"
cd release
ls -l *.zip
cd ~

echo; echo
UPGRADE=""
while [ -z "${UPGRADE}" ]; do
    read -p "Which upgrade package: " UPGRADE
done
unzip release/${UPGRADE} -d release/

printf $info "\n\nCreating Backup \n\n"
source ${SCRIPT_PATH}/backup.sh n
cd ~

printf $info "Stopping Current Containers \n\n"
docker-compose -f core-files/docker-compose.yml stop

printf $info "Unlinking current release \n\n"
rm -rf tak-server

printf $info "Linking new release \n\n"
RELEASE=${UPGRADE/".zip"/""}
ln -s release/${RELEASE} tak-server

printf $info "Copying configurations \n\n"
cp ${BACKUP_PATH}/* tak-server/tak
cp ${CORE_FILES}/.env tak-server/.env

cat tak-server/tak/CoreConfig.xml
cat tak-server/tak/UserAuthenticationFile.xml

printf $info "\n\nsCopying certs \n\n"
mkdir -p tak-server/tak/certs/files/
cp -R ${BACKUP_PATH}/cert-files/* tak-server/tak/certs/files/
ls -la tak-server/tak/certs/files/

printf $info "\n\nRestarting Server with latest version \n\n"
docker-compose -f core-files/docker-compose.yml up  --build  -d

# https://www.joyfulbikeshedding.com/blog/2021-03-15-docker-and-the-host-filesystem-owner-matching-problem.html
GID=$(id -g)
$DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} \
    exec tak-server bash -c "addgroup --gid ${GID} ${USER} && adduser --uid ${UID} --gid ${GID} --gecos \"\" --disabled-password $USER && chown -R $USER:$USER /opt/tak/"

echo
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh
