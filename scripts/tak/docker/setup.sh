#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh
source ${SCRIPT_PATH}/config.inc.sh

# =======================

## Set inputs
#
source ${TAK_SCRIPT_PATH}/v1/inputs.inc.sh "release/takserver*.zip"

## Set firewall rules
#
source ${TAK_SCRIPT_PATH}/v1/firewall.inc.sh
printf $info "\nAllow Docker 5432 [postgres]\n"
sudo ufw allow proto tcp from ${DOCKER_SUBNET} to any port 5432
sudo ufw route allow from ${DOCKER_SUBNET} to ${DOCKER_SUBNET}

printf $warning "\n\n------------ Unpacking Docker Release ------------\n\n"
unzip ~/release/takserver*.zip -d ~/
mv ~/takserver* ${WORK_DIR}
VERSION=$(cat ${TAK_PATH}/version.txt | sed 's/\(.*\)-.*-.*/\1/')

## Set variables for generating CA and client certs
#
source ${TAK_SCRIPT_PATH}/v1/ca-vars.inc.sh

## CoreConfig
#
source ${TAK_SCRIPT_PATH}/v1/coreconfig.inc.sh ${DATABASE_ALIAS}

# Better memory allocation:
# By default TAK server allocates memory based upon the *total* on a machine.
# Allocate memory based upon the available memory so this still scales
#
sed -i "s/MemTotal/MemFree/g" ${TAK_PATH}/setenv.sh

printf $warning "\n\n------------ Creating ENV variable file ${WORK_DIR}/.env ------------\n\n"
# Writes variables to a .env file for docker-compose
#

cat << EOF > ${WORK_DIR}/.env
STATE=$STATE
CITY=$CITY
ORGANIZATION=$ORGANIZATION
ORGANIZATIONAL_UNIT=$ORGANIZATIONAL_UNIT
CAPASS=$CAPASS
PASS=$CERTPASS
TAK_ALIAS=$TAK_ALIAS
NIC=$NIC
TAK_CA=$TAK_CA
URL=$URL
TAK_COT_PORT=$TAK_COT_PORT
IP=$IP
TAK_PATH=/opt/tak
CERT_PATH=$DOCKER_CERT_PATH
EOF

cat ${WORK_DIR}/.env

## Generate Certs
#
source ${TAK_SCRIPT_PATH}/v1/cert-gen.inc.sh

printf $warning "\n\n------------ Configuration Complete. Starting Containers --------------\n\n"
cp ${TEMPLATE_PATH}/tak/docker/docker-compose.yml.tmpl ${WORK_DIR}/docker-compose.yml

sed -i \
    -e "s#__DOCKER_SUBNET#${DOCKER_SUBNET}#g" \
    -e "s/__DATABASE_ALIAS/${DATABASE_ALIAS}/" ${WORK_DIR}/docker-compose.yml

printf $info "------------ Building TAK DB ------------\n\n"
$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml up tak-db -d

printf $info "\n\n------------ Building TAK Server ------------\n\n"
$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml up tak-server -d

ln -s ${TAK_PATH}/logs ${WORK_DIR}/logs

echo; echo
read -p "Do you want to configure TAK Server auto-start [y/n]? " AUTOSTART
cp ${TEMPLATE_PATH}/tak/docker/docker.service.tmpl ${WORK_DIR}/tak-server-docker.service
sed -i "s#__WORK_DIR#${WORK_DIR}#g" ${WORK_DIR}/tak-server-docker.service
sudo rm -rf /etc/systemd/system/tak-server-docker.service
sudo ln -s ${WORK_DIR}/tak-server-docker.service /etc/systemd/system/tak-server-docker.service

if [[ $AUTOSTART =~ ^[Yy]$ ]];then
    sudo systemctl daemon-reload
    sudo systemctl enable tak-server-docker
    printf $info "\nTAK Server auto-start enabled\n\n"
else
    printf $info "\nTAK Server auto-start disabled\n\n"
fi

## Check Server Status
#
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh

$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "useradd $USER && chown -R $USER:$USER \${CERT_PATH}/"

printf $warning "------------ Create Admin --------------\n\n"
## printf $info "You may see several JAVA warnings. This is expected.\n\n"
## This is where things get sketch, as the the server needs to be up and happy
## or everything goes sideways

TAKADMIN_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}

while true;do
    printf $info "\n------------ Enabling Admin User [password and certificate] --------------\n"

    $DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -A -p \"${TAKADMIN_PASS}\" ${TAKADMIN}"
    if [ $? -eq 0 ];then
        $DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar certmod -A \${CERT_PATH}/files/${TAKADMIN}.pem"
        if [ $? -eq 0 ];then
            break
        fi
    fi
    sleep 10
done

printf $success "\n\n ----------------- Installation Complete -----------------\n\n"

## Installation Summary
#
source ${TAK_SCRIPT_PATH}/v1/summary.inc.sh
