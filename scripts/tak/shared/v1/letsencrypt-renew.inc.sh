#!/bin/bash

printf $warning "\n\nRequesting a certificate renewal...\n\n"
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh $(cat ~/letsencrypt.txt)

BACKUP_NAME=$(date +"%Y.%m.%d-%H.%M.%S")
sudo cp ${FILE_PATH}/letsencrypt.jks ${FILE_PATH}/letsencrypt.${BACKUP_NAME}jks
sudo cp ${FILE_PATH}/letsencrypt.p12 ${FILE_PATH}/letsencrypt.${BACKUP_NAME}p12
sudo rm ${FILE_PATH}/letsencrypt*

source ${TOOLS_PATH}/scripts/tak/shared/v1/letsencrypt-import.inc.sh