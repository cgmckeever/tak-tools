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

RELEASE_DIR=~/tak-server/release

CERT_PATH=${RELEASE_DIR}/tak/certs
FILE_PATH=${CERT_PATH}/files

TAK_PATH=/opt/tak

export CITY=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$CITY" | tr -d '\r')
export STATE=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$STATE" | tr -d '\r')
export ORGANIZATION=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$ORGANIZATION" | tr -d '\r')
export ORGANIZATIONAL_UNIT=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$ORGANIZATIONAL_UNIT" | tr -d '\r')
export CAPASS=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
export PASS=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')

printf $warning "\n\n------------ Creating TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

cd ${CERT_PATH}
./makeCert.sh client ${USERNAME}

PASS_OMIT="<>/\'\`\""
USER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)
docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"
docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar certmod -A ${TAK_PATH}/certs/files/${USERNAME}.pem"

printf $info "\nCreated Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"


printf $warning "TAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    docker compose -f ${RELEASE_DIR}/compose.yml restart tak-server
fi

