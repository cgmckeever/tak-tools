#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh
source ${RELEASE_PATH}/config.inc.sh

cd ${RELEASE_PATH}/tak/certs

cp /etc/letsencrypt/live/${TAK_URI}/fullchain.pem files/letsencrypt.pem
cp /etc/letsencrypt/live/${TAK_URI}/privkey.pem files/letsencrypt.key.pem

msg $info "\nImporting LetsEncrypt Certificate"

export PATH=${ROOT_PATH}/jdk/bin:${PATH}

openssl pkcs12 -export \
    -in files/letsencrypt.pem \
    -inkey files/letsencrypt.key.pem \
    -name letsencrypt \
    -out files/letsencrypt.p12 \
    -passout pass:${CA_PASS}

keytool -importkeystore \
    -deststorepass ${CA_PASS} \
    -srcstorepass ${CA_PASS} \
    -destkeystore files/letsencrypt.jks \
    -srckeystore files/letsencrypt.p12 \
    -srcstoretype PKCS12

keytool -import \
    -noprompt \
    -alias lebundle \
    -trustcacerts \
    -deststorepass ${CA_PASS} \
    -srcstorepass ${CA_PASS} \
    -file files/letsencrypt.pem  \
    -keystore files/letsencrypt.jks

keytool -import \
    -noprompt \
    -alias letsencrypt \
    -file files/letsencrypt.pem \
    -keystore files/truststore-${TAK_CA_FILE}-bundle.p12 \
    -storetype PKCS12 \
    -storepass ${CA_PASS}

chmod 644 files/letsencrypt.*