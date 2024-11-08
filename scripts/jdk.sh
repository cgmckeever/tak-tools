#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

install_init

JDK_VERSION="17.0.7"
JDK_TAR="zulu17.42.19-ca-jdk${JDK_VERSION}-${OS}_x64.tar.gz"
JDK_URL="https://cdn.azul.com/zulu/bin/${JDK_TAR}"

TAR_PATH=${ROOT_PATH}/tak-pack
JDK_DIR=jdk

rm -rf ${JDK_DIR}

if [ ! -e "${TAR_PATH}/${JDK_TAR}" ]; then
	msg $warn "Downloading OpenJDK ${JDK_VERSION} for ${OS} ..."
	msg $info ${JDK_URL}
	wget --show-progress -O ${TAR_PATH}/${JDK_TAR} ${JDK_URL}
fi

msg $warn "\nExtracting OpenJDK tak-pack/${JDK_TAR}"
tar -xzf ${TAR_PATH}/${JDK_TAR} 

JDK_INSTALL=$(find . -maxdepth 1 -type d -name "*${JDK_VERSION}*")
mv $JDK_INSTALL ${ROOT_PATH}/$JDK_DIR
msg $success "OpenJDK installed at ${JDK_DIR}/\n"


