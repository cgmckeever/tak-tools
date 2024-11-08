#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

info ${RELEASE_PATH} ""
msg $info "\nCreating new user:"

if [[ "${INSTALLER}" == "docker" ]];then 
    docker_compose
    $DOCKER_COMPOSE -f ${RELEASE_PATH}/docker-compose.yml exec tak-server bash -c "/opt/tak/tak-tools/user-gen.sh ${2} \"${3}\" ${4}"
    CERT_PATH=${RELEASE_PATH}/tak/certs
else 
    # dont source this!
    /opt/tak/tak-tools/user-gen.sh ${2} "${3}" ${4}
    CERT_PATH=/opt/tak/certs
fi

CLIENT_PATH=${CERT_PATH}/files/clients/${2}

CERT_BUNDLE=${CLIENT_PATH}/${2}.${TAK_ALIAS}.certs.${TAK_URI}.zip

msg $info "Creating ${2} full cert bundle"  
zip -j "${CERT_BUNDLE}" \
    ${CERT_PATH}/files/truststore-${TAK_CA_FILE}-bundle.p12 \
    ${CERT_PATH}/files/${2}.* \
    ${CERT_PATH}/files/${2}-*
echo; echo

ENROLL_BUNDLE=${CLIENT_PATH}/${2}.${TAK_ALIAS}.softcert-enroll.${TAK_URI}.zip
msg $info "Creating ${2} softcert bundle" 
zip -j "${ENROLL_BUNDLE}" \
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
MSG="  Full Cert Bundle:"
detail "${MSG}"
MSG="    ${CERT_BUNDLE}"
detail "${MSG}"
MSG="  Soft Cert Bundle:"
detail "${MSG}"
MSG="     ${ENROLL_BUNDLE}"
detail "${MSG}"
echo 


