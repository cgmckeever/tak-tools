#!/bin/bash

ACTIVE_SSL=SELF_SSL
if [[ -f ~/letsencrypt.txt ]]; then
    printf $info "\nUsing LetsEncrypt Certificate\n"
    FQDN=$(cat ~/letsencrypt.txt)
    #LE_CERT_NAME=le-${FQDN//\./-}
    LE_PATH="/etc/letsencrypt/live/$FQDN"

    sudo openssl pkcs12 -export \
        -in ${LE_PATH}/fullchain.pem \
        -inkey ${LE_PATH}/privkey.pem \
        -name letsencrypt \
        -out ${FILE_PATH}/letsencrypt.p12 \
        -passout pass:${CAPASS}

    sudo keytool -importkeystore \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -destkeystore ${FILE_PATH}/letsencrypt.jks \
        -srckeystore ${FILE_PATH}/letsencrypt.p12 \
        -srcstoretype PKCS12

    sudo keytool -import \
        -noprompt \
        -alias bundle \
        -trustcacerts \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -file ${LE_PATH}/fullchain.pem \
        -keystore ${FILE_PATH}/letsencrypt.jks

    printf $info "Enabling LetsEncrypt on Port:8446\n\n"
    URL=$FQDN
    ACTIVE_SSL=LE_SSL
fi