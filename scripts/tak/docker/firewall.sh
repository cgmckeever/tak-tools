#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${TAK_SCRIPT_PATH}/v1/firewall.inc.sh
sudo ufw status numbered