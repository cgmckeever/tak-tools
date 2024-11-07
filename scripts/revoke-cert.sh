#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

msg $info "Revoking Cert for ${2}"
passgen ${USER_PASS_OMIT}

if [[ "${INSTALLER}" == "docker" ]];then 
    ${DOCKER_COMPOSE} -f ${RELEASE_PATH}/docker-compose.yml exec tak-server bash -c "/opt/tak/tak-tools/revoke-cert.sh ${2} \"${PASSGEN}\"" 
else 
    /opt/tak/tak-tools/revoke-cert.sh ${2} "${PASSGEN}"
fi

source ${ROOT_PATH}/scripts/restart-prompt.sh ${1}