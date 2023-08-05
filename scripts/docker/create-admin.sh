#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

RESTART_PROMPT=$1

printf $warning "------------ Create Admin User --------------\n\n"
printf $info "You may see several JAVA warnings. This is expected.\n\n"

PAD1=${PADS:$(( RANDOM % ${#PADS} )) : 1}
PAD2=${PADS:$(( RANDOM % ${#PADS} )) : 1}
TAKADMIN_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}

while true; do
    printf $info "\n------------ Creating --------------\n"

    $DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -A -p \"${TAKADMIN_PASS}\" ${TAKADMIN}"
    if [ $? -eq 0 ];then
        $DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar certmod -A \${CERT_PATH}/files/${TAKADMIN}.pem"
        if [ $? -eq 0 ];then
            break
        fi
    fi
    sleep 10
done

if [[ ! $RESTART_PROMPT =~ ^[Nn]$ ]];then
    printf $warning "TAK needs to restart to enable changes.\n\n"
    read -p "Restart TAK [y/n]? " RESTART

    if [[ $RESTART =~ ^[Yy]$ ]];then
        $DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml restart tak-server
    fi
fi