#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

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
