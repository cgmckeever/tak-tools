#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

export PATH=${ROOT_PATH}/jdk/bin:${PATH}

msg $info "\nChecking CA Trusted pem:"

openssl x509 \
	-in ${RELEASE_PATH}/tak/certs/files/${TAK_CA_FILE}-trusted.pem \
	-text -noout

msg $info "\nChecking Truststore:"

keytool -list -v \
	-keystore ${RELEASE_PATH}/tak/certs/files/truststore-${TAK_CA_FILE}-bundle.p12 \
	-storepass ${CA_PASS} \
	-storetype PKCS12 
