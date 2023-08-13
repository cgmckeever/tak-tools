#!/bin/bash

printf $warning "\n\n------------ Updating CoreConfig.xml ------------\n\n"

sudo touch ${TAK_PATH}/CoreConfig.xml
sudo cp ${TAK_PATH}/CoreConfig.xml ${TAK_PATH}/CoreConfig.xml.install
sudo cp ${TEMPLATE_PATH}/tak/CoreConfig-${VERSION}.xml.tmpl ${TAK_PATH}/CoreConfig.xml

SSL_CERT_INFO=""
if [[ -f ~/letsencrypt.txt ]]; then
    printf $info "\nUsing LetsEncrypt Certificate\n"
    FQDN=$(cat ~/letsencrypt.txt)
    URL=$FQDN
    CERT_NAME=le-${FQDN//\./-}
    LE_PATH="/etc/letsencrypt/live/$FQDN"
    sudo mkdir -p ${CERT_PATH}/letsencrypt

    sudo openssl pkcs12 -export \
        -in ${LE_PATH}/fullchain.pem \
        -inkey ${LE_PATH}/privkey.pem \
        -name ${CERT_NAME} \
        -out ${CERT_PATH}/letsencrypt/${CERT_NAME}.p12 \
        -passout pass:${CAPASS}

    sudo keytool -importkeystore \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -destkeystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.jks \
        -srckeystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.p12 \
        -srcstoretype PKCS12

    sudo keytool -import \
        -noprompt \
        -alias bundle \
        -trustcacerts \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -file ${LE_PATH}/fullchain.pem \
        -keystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.jks

    printf $info "Setting LetsEncrypt on Port:8446\n\n"
    SSL_CERT_INFO="keystore=\"JKS\" keystoreFile=\"${DOCKER_CERT_PATH}/letsencrypt/${CERT_NAME}.jks\" keystorePass=\"__CAPASS\" truststore=\"JKS\" truststoreFile=\"${DOCKER_CERT_PATH}/files/truststore-__TAK_CA.jks\" truststorePass=\"__CAPASS\""
fi

DATABASE_HOST=$1
SIGNING_KEY=${TAK_CA}-signing
PG_PASS=${PAD2}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD1}
sudo sed -i \
    -e "s#__SSL_CERT_INFO#${SSL_CERT_INFO}#g" \
    -e "s/__CAPASS/${CAPASS}/g" \
    -e "s/__PASS/${CERTPASS}/g" \
    -e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
    -e "s/__ORGANIZATION/${ORGANIZATION}/g" \
    -e "s/__TAK_CA/${TAK_CA}/g" \
    -e "s/__SIGNING_KEY/${SIGNING_KEY}/g" \
    -e "s/__CRL/${TAK_CA}/g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__HOSTIP/${URL}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/" \
    -e "s/__DATABASE_HOST/${DATABASE_HOST}/" \
    -e "s/__PG_PASS/${PG_PASS}/" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting CA: ${TAK_CA}\n\n"
printf $info "Setting Cert Password\n\n"
printf $info "Setting Organization Info O: ${ORGANIZATION} OU: ${ORGANIZATIONAL_UNIT}\n\n"
printf $info "Setting Revocation List: ${TAK_CA}.crl\n\n"
printf $info "Setting TAK Server Alias: ${TAK_ALIAS}\n\n"
printf $info "Setting IP/FQDN: ${URL}\n\n"
printf $info "Setting API Port: ${TAK_COT_PORT}\n\n"
printf $info "Setting PostGres URL: ${DATABASE_HOST}\n\n"
printf $info "Setting PostGres Password: ${PG_PASS}\n\n"

pause