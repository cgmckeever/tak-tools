#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

export SSL_PORT=443

# =======================

mkdir -p ${CORE_FILES}
mkdir -p ${WORK_PATH}/logs
mkdir -p ${WORK_PATH}/html
cp ${TEMPLATE_PATH}/nginx/index.html.tmpl ${WORK_PATH}/html/index.html

sudo usermod -aG docker $USER

FQDN=""
NGINX_PORT=80
if [[ -f ~/letsencrypt.txt ]]; then
    IFS=':' read -ra LE_INFO <<< $(cat ~/letsencrypt.txt)
    FQDN=${LE_INFO[0]}
    NGINX_PORT=${SSL_PORT}
fi

## Set firewall rules
#
printf $info "\nAllow Tak Docs port ${NGINX_PORT} \n"
sudo ufw allow ${NGINX_PORT}/tcp
pause

printf $warning "\n\n------------ Configuring Tak Doc --------------\n\n"
cp ${TEMPLATE_PATH}/nginx/Dockerfile.tmpl ${WORK_PATH}/Dockerfile
cp ${TEMPLATE_PATH}/nginx/default.conf.tmpl ${WORK_PATH}/default.conf
cp ${TEMPLATE_PATH}/nginx/docker-compose.yml.tmpl ${DOCKER_COMPOSE_YML}

if [[ ${FQDN} == "" ]]; then
    sed -i \
        -e "#WORK_PATH/ssl#d" ${DOCKER_COMPOSE_YML}

    touch ${WORK_PATH}/ssl.conf
else
    cp ${TEMPLATE_PATH}/nginx/ssl.conf.tmpl ${WORK_PATH}/ssl.conf
    sed -i \
        -e "s/__NGINX_PORT/${NGINX_PORT}/g" ${WORK_PATH}/ssl.conf

    sudo ln -s /etc/letsencrypt/live/${FQDN}/ ${WORK_PATH}/ssl
fi

sed -i \
    -e "s/__NGINX_PORT/${NGINX_PORT}/g" \
    -e "s#__WORK_PATH#${WORK_PATH}#" ${DOCKER_COMPOSE_YML}


printf $info "------------ Building Tak Docs ------------\n\n"
$DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} up tak-docs -d

echo; echo
read -p "Do you want to configure Tak Docs auto-start [y/n]? " AUTOSTART
cp ${TEMPLATE_PATH}/tak/docker/docker.service.tmpl ${CORE_FILES}/${DOCKER_SERVICE}-docker.service

sed -i \
    -e "s#__WORK_PATH#${CORE_FILES}#g" \
    -e "s#__DOCKER_COMPOSE_YML#${DOCKER_COMPOSE_YML}#g" \
    -e "s/__DOCKER_COMPOSE/${DOCKER_COMPOSE}/g" ${CORE_FILES}/${DOCKER_SERVICE}-docker.service
sudo rm -rf /etc/systemd/system/${DOCKER_SERVICE}-docker.service
sudo ln -s ${CORE_FILES}/${DOCKER_SERVICE}-docker.service /etc/systemd/system/${DOCKER_SERVICE}-docker.service
sudo systemctl daemon-reload

if [[ $AUTOSTART =~ ^[Yy]$ ]]; then
    sudo systemctl enable ${DOCKER_SERVICE}-docker
    printf $info "\nTak Docs Server auto-start enabled\n\n"
else
    printf $info "\nTak Docs Server auto-start disabled\n\n"
fi

printf $info "------------ Tak Docs setup complete ------------\n\n"
