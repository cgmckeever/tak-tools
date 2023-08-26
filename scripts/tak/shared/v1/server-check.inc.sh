#!/bin/bash

echo;
START_TIME="$(date -u +%s)"
while true; do
    printf $warning "------------ Waiting for Server to start --------------\n"
    #RESPONSE=$(curl --insecure -I https://${IP}:8446 2>&1)
    RESPONSE=$(curl --insecure -I https://127.0.0.1:8446 2>&1)
    if [ $? -eq 0 ]; then
        END_TIME="$(date -u +%s)"
        printf $success "\n------------ Server Started --------------\n"
        ELAPSED="$((${END_TIME}-${START_TIME}))"
        printf $info "Restart took ${ELAPSED} seconds\n\n"
        break
    fi
    sleep 10
done