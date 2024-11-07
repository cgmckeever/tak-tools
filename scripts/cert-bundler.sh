#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh

BUNDLE="${RELEASE_PATH}/${TAK_ALIAS}.certs.zip"
cd ${RELEASE_PATH}/tak/certs/files
zip -r "${BUNDLE}" * > "${BUNDLE}.log" 2>&1
msg $info "\nCreated cert bundle: ${BUNDLE}" 
echo