#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

source ${SCRIPT_PATH}/functions.inc.sh

msg $warn "\nTAK needs to restart to enable changes."
prompt "Restart TAK [y/N]? " RESTART

if [[ ${RESTART} =~ ^[Yy]$ ]];then
    ${SCRIPT_PATH}/system.sh ${1} restart
fi

