#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================


git config --global --add safe.directory '/opt/tak-tools'
sudo git -C /opt/tak-tools pull

${SCRIPT_PATH}/tear-down.sh
${SCRIPT_PATH}/setup.sh