#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

export PATH=${ROOT_PATH}/jdk/bin:${PATH}

CERT_PATH=${RELEASE_PATH}/tak/certs
CERT_FILE_PATH=${CERT_PATH}/files

cd ${CERT_PATH}
mkdir -p files/clients

cp ${ROOT_PATH}/tak-conf/cert-metadata.sh .

## pre-5.x cert issue
#
if [[ ! -s "${CERT_FILE_PATH}/crl_index.txt.attr" ]]; then
    echo "unique_subject = no" > ${CERT_FILE_PATH}/crl_index.txt.attr
fi

msg $info "\nCreating Root CA"
./makeRootCa.sh --ca-name ${TAK_ROOT_CA}

## No CA is included in Trustsore [??]
#       https://discord.com/channels/698067185515495436/962362215242022912
#
msg $info "\nCreating Bundled Root CA Truststore "
openssl x509 \
    -in files/root-ca-trusted.pem \
    -out files/root-ca-trusted.x509.pem

keytool -importcert -noprompt -alias tak-root-ca \
    -file files/root-ca-trusted.x509.pem \
    -keystore files/truststore-${TAK_CA_FILE}-bundle.p12 \
    -storepass ${CA_PASS} \
    -storetype PKCS12 

msg $info "\nCreating TAK CA"
echo y | ./makeCert.sh ca ${TAK_CA}

rename_files ${CA_PREFIX} takserver ${CERT_FILE_PATH}

## No CA is included in Trustsore [??]
#       https://discord.com/channels/698067185515495436/962362215242022912
#
msg $info "\nAdding CA to Bundled Truststore"
openssl x509 \
    -in files/${TAK_CA_FILE}-trusted.pem \
    -out files/${TAK_CA_FILE}-trusted.x509.pem

keytool -importcert -noprompt -alias tak-intermediary-ca \
    -file files/${TAK_CA_FILE}-trusted.x509.pem \
    -keystore files/truststore-${TAK_CA_FILE}-bundle.p12 \
    -storepass ${CA_PASS} \
    -storetype PKCS12 

msg $info "\nCreating Database Certs"
./makeCert.sh server ${DB_CN}
rename_files ${DB_CN} takdb ${CERT_FILE_PATH}
./makeCert.sh dbclient

msg $info "\nCreating TAK Server Certs"
./makeCert.sh server ${TAK_CN}
rename_files ${TAK_CN} takserver ${CERT_FILE_PATH}

## LETSENCRYPT Cert for 8446 
#
if [ "$LETSENCRYPT" = "true" ] && [ -d "/etc/letsencrypt/live/${TAK_URI}" ];then
    ${ROOT_PATH}/scripts/letsencrypt-import.sh ${TAK_ALIAS}

    ## Create ITAK autoenroll QR (requires trusted cert)
    #
    msg $info "\nGenerating ITAK Connection QR"
    msg $info "  Connection String: ${ITAK_CONN}"
    echo ${ITAK_CONN} | qrencode -s 10 -o ${ITAK_QR_FILE}
else 
    msg $info "\nSkipping LetsEncrypt\n"
fi

## Create autoenroll package
#
msg $info "\nCreating auto-enroll package: ${ENROLL_PACKAGE}"
gen_uuid

sed -e "s/__UUID/${UUID}/g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    ${ROOT_PATH}/tak-conf/manifest.autoenroll.xml.tmpl > files/clients/manifest.xml

sed -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/g" \
    -e "s/__CA_PASS/${CA_PASS}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    -e "s/__TRUSTED_ENROLL/true/g" \
    ${ROOT_PATH}/tak-conf/server.autoenroll.pref.tmpl > files/clients/server.pref

zip -j "${ENROLL_PACKAGE}" \
    files/truststore-${TAK_CA_FILE}-bundle.p12 \
    files/clients/manifest.xml \
    files/clients/server.pref