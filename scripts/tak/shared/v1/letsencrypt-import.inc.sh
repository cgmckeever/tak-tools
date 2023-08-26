#!/bin/bash

if [[ -f ~/letsencrypt.txt ]]; then
    IFS=':' read -ra LE_INFO <<< $(cat ~/letsencrypt.txt)
    FQDN=${LE_INFO[0]}
    printf $info "\nUsing LetsEncrypt Certificate ${FQDN}\n"
    #LE_CERT_NAME=le-${FQDN//\./-}
    LE_PATH="/etc/letsencrypt/live/$FQDN"

    BACKUP_NAME=${NOW}
    sudo touch ${FILE_PATH}/letsencrypt.jks
    sudo cp ${FILE_PATH}/letsencrypt.jks ${FILE_PATH}/letsencrypt.${BACKUP_NAME}.jks
    sudo touch ${FILE_PATH}/letsencrypt.p12
    sudo cp ${FILE_PATH}/letsencrypt.p12 ${FILE_PATH}/letsencrypt.${BACKUP_NAME}.p12
    sudo rm ${FILE_PATH}/letsencrypt*

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
fi