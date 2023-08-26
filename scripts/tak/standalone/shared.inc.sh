#!/bin/bash

PACKAGE_PATH="/tmp"

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"

TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_SCRIPTS=${TOOLS_PATH}/scripts/tak/standalone

TAK_PATH="/opt/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

WHOAMI=$(whoami)

if [[ "$1" == "priv" ]]; then
    if [[ "${WHOAMI}" == "tak" ]]; then
        printf $danger "\nScript should not be run as user: tak\n\n"
        exit 255
    fi
else
    if [[ "${WHOAMI}" != "tak" ]]; then
        printf $danger "\nScript should be run as user: tak\n\n"
        printf $info "change to user: sudo su - tak\n\n"
        exit 255
    fi
fi



