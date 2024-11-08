#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

msg $danger "\nDocker clean up"

CONTAINERS=$(docker ps -q --filter "name=${1}")

if [ -n "${CONTAINERS}" ];then
    msg $warn "\nStopping containers: ${1}"
    docker stop ${CONTAINERS}

    msg $warn "\nRemoving containers: ${1}"
    docker rm ${CONTAINERS}
else
    msg $warn "\nNo containers found with prefix: ${1}"
fi

VOLUME=${1}_tak_data
if docker volume inspect "${VOLUME}" >/dev/null 2>&1; then
    msg $warn "\nRemoving Volume: ${VOLUME}"
    docker volume rm ${VOLUME}
else
    msg $warn "\nNo volume found: ${VOLUME}"
fi

NETWORK=${1}_taknet
if [ -n "$(docker network ls -f name=${NETWORK} -q)" ]; then
    msg $warn "\nRemoving Network: ${NETWORK}"
    docker network rm ${NETWORK}
else
    msg $warn "\nNo network found: ${NETWORK}"
fi

if [ -d "${RELEASE_PATH}" ]; then
    ${SCRIPT_PATH}/cert-bundler.sh ${TAK_ALIAS}

    msg $danger "\nWiping ${RELEASE_PATH}"
    rm -rf ${RELEASE_PATH}
fi


