#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/inc/functions.sh 
source ${SCRIPT_PATH}/inc/configure.sh 

install_init

###########
#
#            INSTALLER
#
##

## TAK Package
#
source scripts/inc/package.sh

## Tear-Down/Clean-up
#
scripts/${INSTALLER}/tear-down.sh ${TAK_ALIAS}

## Generate Config
#
source ${SCRIPT_PATH}/gen-conf.sh

conf ${TAK_ALIAS}
letsencrypt

## Configure
#
if [[ "${INSTALLER}" == "docker" ]];then 
	if ! java -version &> /dev/null;then
		${SCRIPT_PATH}/inc/jdk.sh
	fi

	${SCRIPT_PATH}/docker/unpack.sh ${TAK_PACKAGE} ${RELEASE_PATH}

	filesync
	${SCRIPT_PATH}/inc/cert-gen.sh ${TAK_ALIAS}
	coreconfig

	${SCRIPT_PATH}/docker/compose.sh ${TAK_ALIAS}
else
	coreconfig
	apt install -y ${TAK_PACKAGE}
  	usermod --shell /bin/bash tak
	ln -s /opt/tak ${RELEASE_PATH}/tak
  	echo

  	filesync
  	${SCRIPT_PATH}/inc/cert-gen.sh ${TAK_ALIAS}
  	coreconfig

  	msg $info "\n\nPerforming TAK Server enable:"
	chown -R tak:tak /opt/tak
	systemctl enable takserver
	systemctl daemon-reload
fi

## Init
#
${SCRIPT_PATH}/inc/init.sh ${TAK_ALIAS}



