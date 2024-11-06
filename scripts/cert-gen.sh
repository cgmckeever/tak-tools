#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh
source ${RELEASE_PATH}/config.inc.sh

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

msg $info "\nCreating TAK CA"
echo y | ./makeCert.sh ca ${TAK_CA}

rename_files ${CA_PREFIX} takserver ${CERT_FILE_PATH}

## No CA is included in Trustsore [??]
#
msg $info "\nCreating Bundled Truststore "
openssl x509 \
    -in files/${TAK_CA_FILE}-trusted.pem \
    -out files/${TAK_CA_FILE}-trusted.x509.pem

keytool -importcert -noprompt -alias intermediary-ca \
    -file files/${TAK_CA_FILE}-trusted.x509.pem \
    -keystore files/truststore-${TAK_CA_FILE}-bundle.p12 \
    -storetype PKCS12 \
    -storepass ${CA_PASS}

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
    ITAK_QR_FILE="files/clients/${TAK_ALIAS}.itak-autoenroll.${TAK_URI}.qr.png"
    ITAK_CONN="${TAK_ALIAS}:${TAK_URI},${TAK_URI},${TAK_COT_PORT},SSL"
    msg $info "Connection String: ${ITAK_CONN}"
    echo ${ITAK_CONN} | qrencode -s 10 -o ${ITAK_QR_FILE}
    msg $success "iTAK Connection QR ${ITAK_QR_FILE}"

else 
    msg $info "\nSkipping LetsEncrypt\n"
fi

## Create autoenroll package
#
ENROLL_PACKAGE=files/clients/${TAK_ALIAS}.atak-autoenroll.${TAK_URI}.zip
msg $info "\nCreating autoenroll package: ${ENROLL_PACKAGE}"
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

echo 
info ${RELEASE_PATH} ""
MSG="Autoenroll Cert Package:"
detail "${MSG}"
MSG=${CERT_PATH}/${ENROLL_PACKAGE}
detail "  ${MSG}"

BUNDLE="${RELEASE_PATH}/${TAK_ALIAS}.certs.zip"
msg $info "\nCreating cert bundle: ${BUNDLE}"
zip -r "${BUNDLE}" files/*

echo; echo