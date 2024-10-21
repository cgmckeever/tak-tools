#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../../")

source ${SCRIPT_PATH}/functions.inc.sh

msg $warn "\nTAK needs to restart to enable changes."
prompt "Restart TAK [y/N]? " RESTART

if [[ ${RESTART} =~ ^[Yy]$ ]];then
    ${ROOT_PATH}/scripts/system.sh ${1} restart
fi

