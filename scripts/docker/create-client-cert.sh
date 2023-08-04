#!/bin/bash

color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m      # cyan
color success 92m   # green
color warning 93m   # yellow
color danger 91m    # red

WORK_DIR=~/tak-server
CERT_PATH=${WORK_DIR}/tak/certs
FILE_PATH=${CERT_PATH}/files

export CITY=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CITY" | tr -d '\r')
export STATE=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$STATE" | tr -d '\r')
export ORGANIZATION=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$ORGANIZATION" | tr -d '\r')
export ORGANIZATIONAL_UNIT=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$ORGANIZATIONAL_UNIT" | tr -d '\r')
export CAPASS=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
export PASS=$(docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')

printf $warning "\n\n------------ Creating TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

cd ${CERT_PATH}
./makeCert.sh client ${USERNAME}

PASS_OMIT="<>/\'\`\""
USER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)
docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"

# Admin Priv
# docker compose -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar certmod -A \${TAK_PATH}/certs/files/${USERNAME}.pem"

printf $info "\nCreated Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"


printf $warning "TAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    docker compose -f ${WORK_DIR}/docker-compose.yml restart tak-server
fi

