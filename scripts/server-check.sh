#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
ROOT_PATH=$(realpath "${SCRIPT_PATH}/../")
RELEASE_PATH="${ROOT_PATH}/release/${1}"

source ${SCRIPT_PATH}/functions.inc.sh
source ${RELEASE_PATH}/config.inc.sh

if [ "$INSTALLER" == "docker" ];then
    LOG_PATH=${RELEASE_PATH}/tak/logs/takserver.log
else 
    LOG_PATH=/opt/tak/logs/takserver-api.log
fi

msg $info "Watch the logs:"
msg $info "  tail -f ${LOG_PATH}\n"

START_TIME="$(date -u +%s)"
STARTED="false"
while true; do
    msg $warn "------------ Waiting for Server to start --------------"
    RESPONSE=$(curl --insecure -I https://127.0.0.1:8446 2>&1)
    if [ $? -eq 0 ]; then
        END_TIME="$(date -u +%s)"
        msg $success "\n------------ Server Started --------------"
        ELAPSED="$((${END_TIME}-${START_TIME}))"
        msg $info "Restart took ${ELAPSED} seconds\n"
        STARTED="true"
        break
    fi
    sleep 5
    if cat ${LOG_PATH} 2>/dev/null | grep "error connecting to database";then
        msg $danger "\n\n---------  Error connecting to database has been identified ---------\n"
        STARTED="false"
        break
    fi
done