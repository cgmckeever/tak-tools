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

RELEASE_DIR="${ROOT_PATH}/release"

# Find folders (not files) under the release directory
RELEASE=($(find "$RELEASE_DIR" -mindepth 1 -maxdepth 1 -type d | sort))

if [ ${#RELEASE[@]} -eq 0 ]; then
    msg $warn "No releases found under ${RELEASE_DIR}."
    msg $warn "Please run the configure script to set up the environment."
    exit 1
fi

# Prompt the user
msg $warn "Select a release:"
for i in "${!RELEASE[@]}"; do
    msg $info "$((i+1)). ${RELEASE[$i]##*/}"
done
read -p "Enter a number [1-${#RELEASE[@]}]: " choice

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#RELEASE[@]}" ]; then
    TAK_ALIAS="${RELEASE[$((choice-1))]}"
    msg $warn "${TAK_ALIAS} selected"
else
    msg $warn "Invalid selection. Exiting."
    exit 1
fi

RELEASE_PATH=${ROOT_PATH}/release/${TAK_ALIAS}
conf ${TAK_ALIAS}

## Tear-Down/Clean-up
#
scripts/${INSTALLER}/tear-down.sh ${TAK_ALIAS}

info ${RELEASE_PATH} "---- TAK Info: ${TAK_ALIAS} ----" init
info ${RELEASE_PATH} "Install: ${INSTALLER}"
info ${RELEASE_PATH} "TAK Version: ${VERSION}"
info ${RELEASE_PATH} "TAK Pack: $(basename ${TAK_PACKAGE})"
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Hostname/URI: ${TAK_URI}" 
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Database Info:"
info ${RELEASE_PATH} "  URI: ${TAK_DB_ALIAS}" 
info ${RELEASE_PATH} "  User: martiuser" 
info ${RELEASE_PATH} "  Password: ${TAK_DB_PASS}" 
info ${RELEASE_PATH} ""

letsencrypt

## Configure
#
if [[ "${INSTALLER}" == "docker" ]];then 
	if ! java -version &> /dev/null;then
		${SCRIPT_PATH}/inc/jdk.sh
	fi

	${SCRIPT_PATH}/docker/unpack.sh ${TAK_PACKAGE} ${RELEASE_PATH}

	## Pull container
	## Add layers
	## add scripts to image

	${SCRIPT_PATH}/docker/compose.sh ${TAK_ALIAS}

	## possibly handle in docker-build?
	filesync
	## run cert gen in the container
	${SCRIPT_PATH}/inc/cert-gen.sh ${TAK_ALIAS}
	## configure in docker
	coreconfig
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



