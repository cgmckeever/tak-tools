#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

source ${SCRIPT_PATH}/system.sh ${TAK_ALIAS} start

if [ "$STARTED" = "true" ];then
	info ${RELEASE_PATH} ""
	MSG="Creating TAK ADMIN Account"
	detail "${MSG}"

	passgen ${USER_PASS_OMIT}
	${SCRIPT_PATH}/user-gen.sh ${TAK_ALIAS} ${TAK_ADMIN} "${PASSGEN}" -A

	info ${RELEASE_PATH} ""
	info ${RELEASE_PATH} ""
	MSG="Connection Details:"
	detail "${MSG}"
	MSG="  TAK Credential Login: https://${TAK_URI}:8446"
	detail "${MSG}"
	MSG="  TAK CERT Login: https://${TAK_URI}:8443"
	detail "${MSG}" 
	echo

	echo 
	info ${RELEASE_PATH} ""
	MSG="Auto-enroll Cert Package:"
	detail "${MSG}"
	MSG="${RELEASE_PATH}/tak/certs/${ENROLL_PACKAGE}"
	detail "  ${MSG}"
	info ${RELEASE_PATH} ""
	echo

	if [ -f "${ITAK_QR_FILE}" ];then
        info ${RELEASE_PATH} ""
		MSG="iTAK QR:"
		detail "${MSG}"
		MSG=${ITAK_QR_FILE}
		detail "  ${MSG}"
		echo 
		qrencode -t UTF8 "${ITAK_CONN}"
    fi

	${SCRIPT_PATH}/cert-bundler.sh ${TAK_ALIAS} false

	if [ ! -f "${SCRIPT_PATH}/post-install.sh" ];then
		cp ${SCRIPT_PATH}/post-install-example.sh ${ROOT_PATH}/scripts/post-install.sh
	fi

	echo 
	prompt "Kick off post-install script [y/N]? " POST_INSTALL
	if [[ ${POST_INSTALL} =~ ^[Yy]$ ]];then
	    ${SCRIPT_PATH}/post-install.sh ${TAK_ALIAS}
	fi

	msg $success "\n\nTAK Server installation completed."
else
	msg $warn "\nTAK Server install not successful."
fi

echo;echo