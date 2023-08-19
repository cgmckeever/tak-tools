#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

## create package
#
source ${TAK_SCRIPT_PATH}/v1/autoenroll-data-package.inc.sh