#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${SCRIPT_PATH}/env.inc.sh

printf $warning "\n\n------------ Creating TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

cd ${CERT_PATH}
./makeCert.sh client ${USERNAME}

USER_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}
$DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"

# Admin Priv
# $DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar certmod -A \${TAK_PATH}/certs/files/${USERNAME}.pem"

printf $info "\nCreated Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"

source ${TAK_SCRIPT_PATH}/v1/client-data-package.inc.sh ${USERNAME}

source ${SCRIPT_PATH}/restart-prompt.inc.sh

