#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

##
#   copy this file to post-install.sh
#   	The file post-install.sh is not git-tracked. 
#		Use this to add custom steps after an successful install (ie user-gen)


# ${SCRIPT_PATH}/user-gen.sh ${TAK_ALIAS} recon-5 "your-super-strong-password"
#
# passgen ${USER_PASS_OMIT}
# ${SCRIPT_PATH}/user-gen.sh ${TAK_ALIAS} recon-7 "${PASSGEN}"

