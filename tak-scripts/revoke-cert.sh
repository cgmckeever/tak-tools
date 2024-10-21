#!/bin/bash

source /opt/tak/tak-tools/config.inc.sh

USERNAME=${1}
CERT=files/${USERNAME}.p12
CERT_FILE_PATH=/opt/tak/certs/files

cd /opt/tak/certs

if [[ -f ${CERT} ]]; then
    java -jar /opt/tak/utils/UserManager.jar usermod -p "${2}" ${USERNAME}

    ./revokeCert.sh ${CERT_FILE_PATH}/${USERNAME} ${CERT_FILE_PATH}/${TAK_CA_FILE} ${CERT_FILE_PATH}/${TAK_CA_FILE}

    rm -rf ${CERT_FILE_PATH}/clients/${USERNAME}

    echo
    echo "Revoked Client Certificate cert/${CERT}"
else
    echo "Client Certificate cert/${CERT} not found"
fi