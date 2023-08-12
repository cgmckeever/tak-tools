#!/bin/bash

PACKAGE_PATH="/tmp"

SCRIPT_PATH=="$(dirname "$(readlink -f "$0")")"
echo ${SCRIPT_PATH}

TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_SCRIPTS=${TOOLS_PATH}/scripts/tak/standalone

TAK_PATH="/opt/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

