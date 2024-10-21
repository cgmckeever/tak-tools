#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

##
#   copy this file to post-install.sh
#   	The file post-install.sh is not git-tracked. 
#		Use this to add custom steps after an successful install (ie user-gen)


# ${ROOT_PATH}/scripts/user-gen.sh ${TAK_ALIAS} recon-5 "your-super-strong-password"
#
# passgen ${USER_PASS_OMIT}
# ${ROOT_PATH}/scripts/user-gen.sh ${TAK_ALIAS} recon-7 "${PASSGEN}"

