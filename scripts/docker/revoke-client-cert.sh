#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

TAK_CA=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_CA" | tr -d '\r')
export CITY=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CITY" | tr -d '\r')
export STATE=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$STATE" | tr -d '\r')
export ORGANIZATION=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$ORGANIZATION" | tr -d '\r')
export ORGANIZATIONAL_UNIT=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$ORGANIZATIONAL_UNIT" | tr -d '\r')
export CAPASS=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
export PASS=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')

printf $warning "\n\n------------ Revoking TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

if [[ -f ${FILE_PATH}/${USERNAME}.p12 ]]; then
    PASS_OMIT="<>/\'\`\""
    USER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)
    docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"

    cd ${CERT_PATH}
    ./revokeCert.sh ${FILE_PATH}/${USERNAME} ${FILE_PATH}/${TAK_CA} ${FILE_PATH}/${TAK_CA}

    rm -rf ${FILE_PATH}/clients/$USERNAME

    printf $info "\nRevoked Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"

    printf $warning "TAK needs to restart to enable changes.\n\n"
    read -p "Restart TAK [y/n]? " RESTART

    if [[ $RESTART =~ ^[Yy]$ ]];then
        docker compose -f ${WORK_DIR}/docker-compose.yml restart tak-server
    fi
else
    printf $warning "\nClient Certificate ${FILE_PATH}/${USERNAME}.p12 not found\n\n"
fi


