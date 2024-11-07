#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

msg $info "Revoking Cert for ${2}"
passgen ${USER_PASS_OMIT}

if [[ "${INSTALLER}" == "docker" ]];then 
    docker_compose
    ${DOCKER_COMPOSE} -f ${RELEASE_PATH}/docker-compose.yml exec tak-server bash -c "/opt/tak/tak-tools/revoke-cert.sh ${2} \"${PASSGEN}\"" 
else 
    /opt/tak/tak-tools/revoke-cert.sh ${2} "${PASSGEN}"
fi

source ${ROOT_PATH}/scripts/restart-prompt.sh ${1}