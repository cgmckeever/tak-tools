#!/bin/bash

PACKAGE_PATH="/tmp'

TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_PATH="/opt/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

