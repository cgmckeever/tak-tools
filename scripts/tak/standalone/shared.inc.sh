#!/bin/bash

WORK_DIR=~/tak-server # Base directory; where everything kicks off

TOOLS_PATH=$(dirname $(dirname $(dirname $SCRIPT_PATH)))
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

TAK_PATH="/opt/tak"
source ${TOOLS_PATH}/scripts/tak/shared/vars.inc.sh

