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

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TOOLS_DIR=$(dirname $(dirname $SCRIPT_DIR))
TEMPLATE_DIR="${TOOLS_DIR}/templates"


WORK_DIR=~/tak-server
rm -rf $WORK_DIR
mkdir -p $WORK_DIR

unzip /tmp/takserver*.zip -d ${WORK_DIR}/; \
mv ${WORK_DIR}/tak* ${WORK_DIR}/release;
chown -R $USER:$USER ${WORK_DIR}
VERSION=$(cat ${WORK_DIR}/release/tak/version.txt | sed 's/\(.*\)-.*-.*/\1/')

TAKADMIN=tak-admin
TAKADMIN_PASS=$(pwgen -cvy1 25)

PG_PASS=$(pwgen -cvy1 25)

echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}')
read -p "Which Network Interface [${DEFAULT_NIC}]? " NIC
NIC=${NIC:-$DEFAULT_NIC}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)


## CoreConfig
#
cp ${TEMPLATE_DIR}/CoreConfig-${VERSION}.xml.tmpl ${WORK_DIR}/CoreConfig.xml
sed -i "s/PG_PASS/${PG_PASS}/" ${WORK_DIR}/CoreConfig.xml
sed -i "s/HOSTIP/${IP}/g" ${WORK_DIR}/CoreConfig.xml

# Replaces takserver.jks with $IP.jks
#sed -i "s/takserver.jks/$IP.jks/g" tak/CoreConfig.xml


# Better memory allocation:
# By default TAK server allocates memory based upon the *total* on a machine.
# Allocate memory based upon the available memory so this still scales
#
sed -i "s/MemTotal/MemFree/g" ${WORK_DIR}/release/tak/setenv.sh

## Set variables for generating CA and client certs
#
printf $warning "SSL setup. Hit enter (x3) to accept the defaults:\n"
read -p "State (for cert generation). Default [state] :" STATE
export STATE=${STATE:-state}

read -p "City (for cert generation). Default [city]:" CITY
export CITY=${CITY:-city}

read -p "Organizational Unit (for cert generation). Default [org]:" ORGANIZATIONAL_UNIT
export ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-orgunit}


# Writes variables to a .env file for docker-compose
#
cat << EOF > ${WORK_DIR}/.env
STATE=$STATE
CITY=$CITY
ORGANIZATIONAL_UNIT=$ORGANIZATIONAL_UNIT
EOF

docker compose --file ${SCRIPT_DIR}/docker/compose.yml --force-recreate -d