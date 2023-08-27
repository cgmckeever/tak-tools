#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

export ACTIVE_SSL=${TAK_ACTIVE_SSL}

## create package
#
source ${TAK_SCRIPT_PATH}/v1/autoenroll-data-package.inc.sh