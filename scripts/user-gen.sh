#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

msg $info "\nCreating ${2} user"

if [[ "${INSTALLER}" == "docker" ]];then 
    $DOCKER_COMPOSE -f ${RELEASE_PATH}/docker-compose.yml exec tak-server bash -c "/opt/tak/tak-tools/user-gen.sh ${2} \"${3}\" ${4}"
    CERT_PATH=${RELEASE_PATH}/tak/certs
else 
    # dont source this!
    /opt/tak/tak-tools/user-gen.sh ${2} "${3}" ${4}
    CERT_PATH=/opt/tak/certs
fi

CLIENT_PATH=${CERT_PATH}/files/clients/${2}

CERT_BUNDLE=${CLIENT_PATH}/${2}.${TAK_ALIAS}-${TAK_URI}.zip
zip -j "${CERT_BUNDLE}" \
    ${CERT_PATH}/files/truststore-${TAK_CA_FILE}-bundle.p12 \
    ${CERT_PATH}/files/${2}.p12 \
    ${CLIENT_PATH}/manifest.xml \
    ${CLIENT_PATH}/server.pref
echo; echo

MSG="User Information:"
detail "${MSG}"
MSG="  Username: ${2}"
detail "${MSG}"
MSG="  Password: ${3}"
detail "${MSG}"
MSG="  Cert Bundle:"
detail "${MSG}"
MSG="     ${CERT_BUNDLE}"
detail "${MSG}"
echo 


