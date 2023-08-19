#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

printf $warning "\n\n------------ Revoking TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

if [[ -f ${FILE_PATH}/${USERNAME}.p12 ]]; then
    USER_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}
    $DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"

    cd ${CERT_PATH}
    ./revokeCert.sh ${FILE_PATH}/${USERNAME} ${FILE_PATH}/${TAK_CA} ${FILE_PATH}/${TAK_CA}

    rm -rf ${FILE_PATH}/clients/$USERNAME

    printf $info "\nRevoked Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"

    printf $warning "TAK needs to restart to enable changes.\n\n"
    read -p "Restart TAK [y/n]? " RESTART

    if [[ $RESTART =~ ^[Yy]$ ]];then
        $DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} restart tak-server
    fi
else
    printf $warning "\nClient Certificate ${FILE_PATH}/${USERNAME}.p12 not found\n\n"
fi


