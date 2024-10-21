#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")

source ${SCRIPT_PATH}/../functions.inc.sh

if apt list --installed 2>/dev/null | grep -q "takserver";then
	msg $warn "\nTAK Server clean up (takes a moment to stop TAK)"
	systemctl stop takserver
	sleep 10
	apt remove -y takserver

	msg $warn "\nTAK Database clean up"
	sudo -u postgres psql -c "DROP DATABASE IF EXISTS cot;" 
	sudo -u postgres psql -c "DROP USER IF EXISTS martiuser;"
fi

rm -rf /opt/tak