#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh
source ${RELEASE_PATH}/config.inc.sh

source ${ROOT_PATH}/scripts/system.sh ${TAK_ALIAS} start

if [ "$STARTED" = "true" ];then
	info ${RELEASE_PATH} ""
	info ${RELEASE_PATH} ""
	MSG="TAK ADMIN"
	detail "${MSG}"

	passgen ${USER_PASS_OMIT}
	${ROOT_PATH}/scripts/user-gen.sh ${TAK_ALIAS} ${TAK_ADMIN} "${PASSGEN}" -A

	echo 
	info ${RELEASE_PATH} ""
	info ${RELEASE_PATH} ""
	MSG="Connection Details:"
	detail "${MSG}"
	MSG="  TAK Credential Login: https://${TAK_URI}:8446"
	detail "${MSG}"
	MSG="  TAK CERT Login: https://${TAK_URI}:8443"
	detail "${MSG}" 
	echo
else
	msg $warn "\nTAK Server install not successful."
fi