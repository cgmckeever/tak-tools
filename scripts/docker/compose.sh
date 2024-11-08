#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

docker_compose

sed -e "s#__DOCKER_SUBNET#${DOCKER_SUBNET}#g" \
    -e "s/__TAK_DB_ALIAS/${TAK_DB_ALIAS}/" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/g" \
    -e "s|__WORK_PATH|${RELEASE_PATH}|g" \
    ${ROOT_PATH}/tak-conf/docker-compose.yml.tmpl > ${RELEASE_PATH}/docker-compose.yml

sed -e "s/__DOCKER_COMPOSE/${DOCKER_COMPOSE}/g" \
    -e "s/__DOCKER_COMPOSE_YAML/docker-compose.yml/g" \
    -e "s|__WORK_PATH|${RELEASE_PATH}|g" \
    ${ROOT_PATH}/tak-conf/docker.service.tmpl > ${RELEASE_PATH}/docker.service


