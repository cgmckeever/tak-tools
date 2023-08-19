#!/bin/bash

cd ${BACKUP_PATH}
zip -r ${BACKUPS}/${TAK_ALIAS}-${BACKUP_NAME}.zip *

printf $info "\n\ncreated ${BACKUPS}/${TAK_ALIAS}-${BACKUP_NAME}.zip\n\n"

if [[ ${1} == "" ]]; then
    rm -rf ${BACKUP_PATH}
fi