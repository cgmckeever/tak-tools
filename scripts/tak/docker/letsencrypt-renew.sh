#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

printf $warning "\n\nRequesting a certificate renewal...\n\n"
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh

source ${TOOLS_PATH}/scripts/tak/shared/v1/letsencrypt-import.inc.sh