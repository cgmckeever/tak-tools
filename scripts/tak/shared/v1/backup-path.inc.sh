#!/bin/bash

BACKUP_NAME=$(date +"%Y.%m.%d-%H.%M.%S")
BACKUP_PATH=${BACKUPS}/${BACKUP_NAME}
mkdir -p ${BACKUP_PATH}/cert-files

cp -R ${FILE_PATH}/* ${BACKUP_PATH}/cert-files
cp ${TAK_PATH}/CoreConfig.xml ${BACKUP_PATH}/
cp ${TAK_PATH}/UserAuthenticationFile.xml ${BACKUP_PATH}/

