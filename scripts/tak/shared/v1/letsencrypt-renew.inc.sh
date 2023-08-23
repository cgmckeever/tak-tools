#!/bin/bash

printf $warning "\n\nRequesting a certificate renewal...\n\n"
IFS=':' read -ra LE_INFO <<< $(cat ~/letsencrypt.txt)
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh ${LE_INFO[0]} ${LE_INFO[1]}

BACKUP_NAME=$(date +"%Y.%m.%d-%H.%M.%S")
sudo cp ${FILE_PATH}/letsencrypt.jks ${FILE_PATH}/letsencrypt.${BACKUP_NAME}.jks
sudo cp ${FILE_PATH}/letsencrypt.p12 ${FILE_PATH}/letsencrypt.${BACKUP_NAME}.p12
sudo rm ${FILE_PATH}/letsencrypt*

source ${TOOLS_PATH}/scripts/tak/shared/v1/letsencrypt-import.inc.sh