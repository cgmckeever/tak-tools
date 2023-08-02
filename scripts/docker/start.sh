#!/bin/bash

## TODO: Separate script?
#
color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m
color success 92m
color warning 93m
color danger 91m

CAPASS="atakatak"

WORK_DIR=~/tak-server
RELEASE_DIR="${WORK_DIR}/release"
TAK_DIR="${RELEASE_DIR}/tak"

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TOOLS_DIR=$(dirname $(dirname $SCRIPT_DIR))
TEMPLATE_DIR="${TOOLS_DIR}/templates"

sudo rm -rf $WORK_DIR
mkdir -p $WORK_DIR

unzip /tmp/takserver*.zip -d ${WORK_DIR}/
mv ${WORK_DIR}/tak* ${RELEASE_DIR}/
chown -R $USER:$USER ${WORK_DIR}
VERSION=$(cat ${TAK_DIR}/version.txt | sed 's/\(.*\)-.*-.*/\1/')

TAKADMIN=tak-admin
TAKADMIN_PASS=$(pwgen -cvy1 -r "<>" 25)

PG_PASS=$(pwgen -cvy1 -r "<>" 25)

echo; echo
HOSTNAME=${HOSTNAME//\./-}
read -p "What is the alias of this Tak Server [${HOSTNAME}]? " TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-$HOSTNAME}

INTERMEDIARY_CA=${TAK_ALIAS}-Intermediate-CA

echo; echo
ip link show
echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}')
read -p "Which Network Interface [${DEFAULT_NIC}]? " NIC
NIC=${NIC:-${DEFAULT_NIC}}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)

sudo ufw allow proto tcp from ${IP}/24 to any port 8089
sudo ufw allow proto tcp from ${IP}/24 to any port 8443
sudo ufw allow proto tcp from ${IP}/24 to any port 8446

## Set variables for generating CA and client certs
#
printf $warning "SSL setup. Hit enter (x4) to accept the defaults:\n"
read -p "State (for cert generation). Default [state] :" STATE
export STATE=${STATE:-state}

read -p "City (for cert generation). Default [city]:" CITY
export CITY=${CITY:-city}

read -p "Organization Name (for cert generation) [TAK]:" ORGANIZATION
export ORGANIZATION=${ORGANIZATION:-TAK}

read -p "Organizational Unit (for cert generation). Default [${ORGANIZATION}]:" ORGANIZATIONAL_UNIT
export ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-${ORGANIZATION}}

## CoreConfig
#
cp ${TEMPLATE_DIR}/CoreConfig-${VERSION}.xml.tmpl ${TAK_DIR}/CoreConfig.xml
sed -i "s/__PG_PASS/${PG_PASS}/" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__HOSTIP/${IP}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATION/${ORGANIZATION}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__CAPASS/${CAPASS}/g" ${TAK_DIR}/CoreConfig.xml

# Replaces takserver.jks with $IP.jks
#sed -i "s/takserver.jks/$IP.jks/g" tak/CoreConfig.xml


# Better memory allocation:
# By default TAK server allocates memory based upon the *total* on a machine.
# Allocate memory based upon the available memory so this still scales
#
sed -i "s/MemTotal/MemFree/g" ${TAK_DIR}/setenv.sh


# Writes variables to a .env file for docker-compose
#
cat << EOF > ${RELEASE_DIR}/.env
STATE=$STATE
CITY=$CITY
ORGANIZATIONAL_UNIT=$ORGANIZATIONAL_UNIT
CAPASS=$CAPASS
TAK_ALIAS=$TAK_ALIAS
NIC=$NIC
EOF

cp ${TOOLS_DIR}/docker/compose.yml ${RELEASE_DIR}/
docker compose -f ${RELEASE_DIR}/compose.yml up --force-recreate -d

## Certs
#
sleep 20

while true;do
    printf $warning "------------CERTIFICATE GENERATION--------------\n"

    docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd /opt/tak/certs && ./makeRootCa.sh --ca-name ${TAK_ALIAS}-CA"
    if [ $? -eq 0 ];then
        docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd /opt/tak/certs && ./makeCert.sh ca ${INTERMEDIARY_CA}"
        if [ $? -eq 0 ];then
            docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd /opt/tak/certs && ./makeCert.sh server ${TAK_ALIAS}"
            if [ $? -eq 0 ];then
                docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd /opt/tak/certs && ./makeCert.sh client ${TAKADMIN}"
                if [ $? -eq 0 ];then
                    docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "useradd $USER && chown -R $USER:$USER /opt/tak/certs/"
                    docker compose -f ${RELEASE_DIR}/compose.yml stop tak-server
                    break
                fi
            fi
        fi
    fi
    sleep 10
done

docker compose -f ${RELEASE_DIR}/compose.yml start tak-server


printf $warning "\n\nImport the $TAKADMIN.p12 certificate from this folder to your browser as per the README.md file\n"
printf $success "Login at https://$IP:8443 with your admin account. No need to run the /setup step as this has been done.\n"
printf $info "Certificates and *CERT DATA PACKAGES* are in tak/certs/files \n\n"

printf $info "Execute into running container `docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash` \n\n"

printf $danger "---------PASSWORDS----------------\n\n"
printf $danger "Tak Admin user name: $TAKADMIN\n"
printf $danger "Tak Admin password: $TAKADMIN_PASS\n"
printf $danger "PostgreSQL password: $PG_PASS\n\n"
printf $danger "---------PASSWORDS----------------\n\n"
