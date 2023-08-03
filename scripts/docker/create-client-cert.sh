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

CERT_PATH=~/tak-server/release/tak/certs
FILE_PATH=${CERT_PATH}/files

printf $warning "\n\n------------ Creating TAK Client Certificate ------------ \n\n"

read -p "What is the username: " USERNAME

${CERT_PATH}/makeCert.sh client ${USERNAME}

printf $info "Creatied Client Certificate ${FILE_PATH}/${USERNAME}.p12\n\n"


printf $warning "TAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]" RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    docker compose -f tak-server/release/compose.yml restart tak-server
fi

