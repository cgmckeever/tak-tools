#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

export CAPASS=${TAK_CAPASS}

source ${TAK_SCRIPT_PATH}/v1/letsencrypt-renew.inc.sh