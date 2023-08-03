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

printf $warning "\n\n------------ Revoking TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

cd ${CERT_PATH}
./revokeCert.sh ${FILE_PATH}/${USERNAME} ${FILE_PATH}/ca-do-not-share ${FILE_PATH}//ca

PASS_OMIT="<>/\'\`\""
USER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)
docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar usermod -p \"${USER_PASS}\" $USERNAME"

printf $info "\nRevoked Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"


printf $warning "TAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    docker compose -f ${RELEASE_DIR}/compose.yml restart tak-server
fi
