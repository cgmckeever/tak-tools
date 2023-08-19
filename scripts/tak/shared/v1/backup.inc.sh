#!/bin/bash

BACKUP_NAME=$(date +"%Y.%m.%d-%H.%M.%S")
BACKUP_PATH=${BACKUPS}/${BACKUP_NAME}
mkdir -p ${BACKUP_PATH}/cert-files

cp -R ${FILE_PATH}/* ${BACKUP_PATH}/cert-files
cp ${TAK_PATH}/CoreConfig.xml ${BACKUP_PATH}/
cp ${TAK_PATH}/UserAuthenticationFile.xml ${BACKUP_PATH}/

cd ${BACKUP_PATH}
zip -r ${BACKUPS}/${TAK_ALIAS}-${BACKUP_NAME}.zip *

printf $info "\n\ncreated {BACKUPS}/${TAK_ALIAS}-${BACKUP_NAME}.zip\n\n"

if [[ ${1} == "" ]]; then
    rm -rf ${BACKUP_PATH}
fi