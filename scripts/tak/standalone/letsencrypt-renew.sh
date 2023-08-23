#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

export CAPASS=${TAK_CAPASS}

printf $warning "\n\nRequesting a certificate renewal...\n\n"
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh

BACKUP_NAME=$(date +"%Y.%m.%d-%H.%M.%S")
cp ${FILE_PATH}/letsencrypt.jks ${FILE_PATH}/letsencrypt.${BACKUP_NAME}jks
cp ${FILE_PATH}/letsencrypt.p12 ${FILE_PATH}/letsencrypt.${BACKUP_NAME}p12
source ${TOOLS_PATH}/scripts/tak/shared/v1/letsencrypt-import.inc.sh