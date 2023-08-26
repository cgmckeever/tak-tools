#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

export CITY=${TAK_CITY}
export STATE=${TAK_STATE}
export ORGANIZATION=${TAK_ORGANIZATION}
export ORGANIZATIONAL_UNIT=${TAK_ORGANIZATIONAL_UNIT}

export CAPASS=${TAK_CAPASS}
export PASS=${TAK_PASS}

printf $warning "\n\n------------ Revoking TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

if [[ -f ${FILE_PATH}/${USERNAME}.p12 ]]; then
    USER_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}
    java -jar ${TAK_PATH}/utils/UserManager.jar usermod -p "${USER_PASS}" $USERNAME

    cd ${CERT_PATH}
    ./revokeCert.sh ${FILE_PATH}/${USERNAME} ${FILE_PATH}/${TAK_CA} ${FILE_PATH}/${TAK_CA}

    rm -rf ${FILE_PATH}/clients/$USERNAME

    printf $info "\nRevoked Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"

    source ${SCRIPT_PATH}/restart-prompt.inc.sh
else
    printf $warning "\nClient Certificate ${FILE_PATH}/${USERNAME}.p12 not found\n\n"
fi