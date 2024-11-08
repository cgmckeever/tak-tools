#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

if apt list --installed 2>/dev/null | grep -q "takserver";then
	msg $warn "\nTAK Server clean up (takes a moment to stop TAK)"
	systemctl stop takserver
	sleep 10
	systemctl disable takserver
	apt remove -y takserver

	msg $warn "\nTAK Database clean up"
	sudo -u postgres psql -c "DROP DATABASE IF EXISTS cot;" 
	sudo -u postgres psql -c "DROP USER IF EXISTS martiuser;"
fi

if [ -d "${RELEASE_PATH}" ]; then
	${SCRIPT_PATH}/cert-bundler.sh ${TAK_ALIAS}

	msg $danger "\nWiping ${RELEASE_PATH}"
	rm -rf ${RELEASE_PATH}

	msg $danger "\nWiping /opt/tak"
	rm -rf /opt/tak
fi