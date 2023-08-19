#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh
source ${TAK_SCRIPT_PATH}/v1/backup-path.inc.sh

cp ${CORE_FILES}/* ${BACKUP_PATH}/

source ${TAK_SCRIPT_PATH}/v1/backup-zip.inc.sh $1

