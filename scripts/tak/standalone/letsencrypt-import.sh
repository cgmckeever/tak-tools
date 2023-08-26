#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh priv

# =======================

export CAPASS=${TAK_CAPASS}

source ${TAK_SCRIPT_PATH}/v1/letsencrypt-import.inc.sh
source ${SCRIPT_PATH}/restart-prompt.inc.sh