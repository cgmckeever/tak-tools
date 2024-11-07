#!/bin/bash

source /opt/tak/tak-tools/functions.inc.sh tak

USERNAME=${1}
CERT=files/${USERNAME}.p12
CERT_FILE_PATH=/opt/tak/certs/files

cd /opt/tak/certs

if [[ -f ${CERT} ]]; then
    java -jar /opt/tak/utils/UserManager.jar usermod -p "${2}" ${USERNAME}

    ./revokeCert.sh ${CERT_FILE_PATH}/${USERNAME} ${CERT_FILE_PATH}/${TAK_CA_FILE} ${CERT_FILE_PATH}/${TAK_CA_FILE}

    rm -rf ${CERT_FILE_PATH}/clients/${USERNAME}

    msg $warn "\nRevoked Client Certificate cert/${CERT}"
else
    echo "Client Certificate cert/${CERT} not found"
    msg $danger "Client Certificate cert/${CERT} not found"
fi