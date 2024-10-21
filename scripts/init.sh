#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

source ${ROOT_PATH}/scripts/system.sh ${TAK_ALIAS} start

if [ "$STARTED" = "true" ];then
	info ${RELEASE_PATH} ""
	MSG="TAK ADMIN"
	detail "${MSG}"

	passgen ${USER_PASS_OMIT}
	${ROOT_PATH}/scripts/user-gen.sh ${TAK_ALIAS} ${TAK_ADMIN} "${PASSGEN}" -A

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

	if [ -f "${ITAK_QR_FILE}" ]; then
        info ${RELEASE_PATH} ""
		MSG="iTAK QR:"
		detail "${MSG}"
		MSG=${ITAK_QR_FILE}
		detail "  ${MSG}"
		echo 
		qrencode -t UTF8 "${ITAK_CONN}"
    fi

	${ROOT_PATH}/scripts/cert-bundler.sh ${TAK_ALIAS}

	if [ ! -f "${ROOT_PATH}/scripts/post-install.sh" ]; then
		cp ${ROOT_PATH}/scripts/post-install-example.sh ${ROOT_PATH}/scripts/post-install.sh
	fi

	echo 
	prompt "Kick off post-install script [y/N]? " POST_INSTALL
	if [[ ${POST_INSTALL} =~ ^[Yy]$ ]];then
	    ${ROOT_PATH}/scripts/post-install.sh ${TAK_ALIAS}
	fi

	msg $success "\n\nTAK Server installation completed."
else
	msg $warn "\nTAK Server install not successful.\n\n"
fi