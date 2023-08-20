#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

printf $warning "\n\nAvailable Releases: \n\n"
ls release/*.zip

echo; echo
UPGRADE=""
while [ -z "${UPGRADE}" ]; do
    read -p "Which upgrade package: " UPGRADE
done
pause
unzip release/${UPGRADE} -d release/

printf $info "\n\nCreating Backup \n\n"
source ${SCRIPT_PATH}/backup.sh n

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

printf $info "Copying certs \n\n"
mkdir -p tak-server/tak/certs/files/
cp -R ${BACKUP_PATH}/cert-files/* tak-server/tak/certs/files/
ls -la tak-server/tak/certs/files/

printf $info "Restarting Server \n\n"
docker-compose -f core-files/docker-compose.yml up  --build  -d

echo
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh
