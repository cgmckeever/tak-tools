#!/bin/bash

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
TOOLS_PATH=$(dirname $SCRIPT_PATH)
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

# =======================

source ${TAK_SCRIPT_PATH}/v1/letsencrypt-import.inc.sh
source ${SCRIPT_PATH}/restart-prompt.inc.sh