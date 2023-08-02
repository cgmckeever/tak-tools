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
CERTPASS="atakatak"
DOCKER_SUBNET="172.20.0.0/24"

WORK_DIR=~/tak-server
RELEASE_DIR="${WORK_DIR}/release"
TAK_DIR="${RELEASE_DIR}/tak"
CERT_DIR="${TAK_DIR}/certs"

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TOOLS_DIR=$(dirname $(dirname $SCRIPT_DIR))
TEMPLATE_DIR="${TOOLS_DIR}/templates"

TAK_PATH="/opt/tak"
CERT_PATH="${TAK_PATH}/certs"

sudo rm -rf $WORK_DIR
mkdir -p $WORK_DIR

unzip /tmp/takserver*.zip -d ${WORK_DIR}/
mv ${WORK_DIR}/tak* ${RELEASE_DIR}/
chown -R $USER:$USER ${WORK_DIR}
VERSION=$(cat ${TAK_DIR}/version.txt | sed 's/\(.*\)-.*-.*/\1/')

PASS_OMIT="<>/\'\`\""

TAKADMIN=tak-admin
TAKADMIN_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)

PG_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 25)

echo; echo
HOSTNAME=${HOSTNAME//\./-}
read -p "Alias of this Tak Server: Default [${HOSTNAME}]? " TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-$HOSTNAME}

INTERMEDIARY_CA=${TAK_ALIAS}-Intermediate-CA

echo; echo
ip link show
echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}')
read -p "Which Network Interface? Default [${DEFAULT_NIC}]? " NIC
NIC=${NIC:-${DEFAULT_NIC}}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)
URL=$IP

sudo ufw allow proto tcp from ${IP}/24 to any port 8089
sudo ufw allow proto tcp from ${IP}/24 to any port 8443
sudo ufw allow proto tcp from ${IP}/24 to any port 8446
sudo ufw allow proto tcp from ${IP}/24 to any port 9000
sudo ufw allow proto tcp from ${IP}/24 to any port 9001
sudo ufw allow proto tcp from ${DOCKER_SUBNET} to any port 5432
sudo ufw route allow from ${DOCKER_SUBNET} to ${DOCKER_SUBNET}

## Set variables for generating CA and client certs
#
printf $warning "SSL setup. Hit enter (x4) to accept the defaults:\n"
read -p "State (for cert generation). Default [state] : " STATE
export STATE=${STATE:-state}

read -p "City (for cert generation). Default [city]: " CITY
export CITY=${CITY:-city}

read -p "Organization Name (for cert generation) Default [TAK]: " ORGANIZATION
export ORGANIZATION=${ORGANIZATION:-TAK}

read -p "Organizational Unit (for cert generation). Default [${ORGANIZATION}]: " ORGANIZATIONAL_UNIT
export ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-${ORGANIZATION}}

## CoreConfig
#
cp ${TEMPLATE_DIR}/CoreConfig-${VERSION}.xml.tmpl ${TAK_DIR}/CoreConfig.xml

SSL_CERT_INFO=""
cat ~/letsencrypt.txt
if [[ -f ~/letsencrypt.txt ]]; then
    FQDN=$(cat ~/letsencrypt.txt)
    URL=$FQDN
    CERT_NAME=le-${FQDN//\./-}
    LE_DIR="/etc/letsencrypt/live/$FQDN"
    mkdir -p ${CERT_DIR}/files

    sudo openssl pkcs12 -export \
        -in ${LE_DIR}/fullchain.pem \
        -inkey ${LE_DIR}/privkey.pem \
        -name ${CERT_NAME} \
        -out ${CERT_DIR}/files/${CERT_NAME}.p12 \
        -passout pass:${CAPASS}

    sudo keytool -importkeystore \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -destkeystore ${CERT_DIR}/files/${CERT_NAME}.jks \
        -srckeystore ${CERT_DIR}/files/${CERT_NAME}.p12 \
        -srcstoretype PKCS12

    sudo keytool -import \
        -noprompt \
        -alias bundle \
        -trustcacerts \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -file ${LE_DIR}/fullchain.pem \
        -keystore ${CERT_DIR}/files/${CERT_NAME}.jks

    SSL_CERT_INFO="keystore=\"JKS\" keystoreFile=\"${CERT_PATH}/files/${CERT_NAME}.jks\" keystorePass=\"__CAPASS\" truststore=\"JKS\" truststoreFile=\"${CERT_PATH}/files/truststore-__TRUSTSTORE.jks\" truststorePass=\"__CAPASS\""
fi

sed -i "s#__SSL_CERT_INFO#${SSL_CERT_INFO}#g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__CAPASS/${CAPASS}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATION/${ORGANIZATION}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__TRUSTSTORE/${INTERMEDIARY_CA}/g" ${TAK_DIR}/CoreConfig.xml

SIGNING_KEY=${INTERMEDIARY_CA}-signing
sed -i "s/__SIGNING_KEY/${SIGNING_KEY}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__CRL/${__INTERMEDIARY_CA}/g" ${TAK_DIR}/CoreConfig.xml

sed -i "s/__TAK_ALIAS/${TAK_ALIAS}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__HOSTIP/${URL}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__PG_PASS/${PG_PASS}/" ${TAK_DIR}/CoreConfig.xml

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
ORGANIZATION=$ORGANIZATION
ORGANIZATIONAL_UNIT=$ORGANIZATIONAL_UNIT
CAPASS=$CAPASS
PASS=$CERTPASS
TAK_ALIAS=$TAK_ALIAS
NIC=$NIC
INTERMEDIARY_CA=$INTERMEDIARY_CA
EOF

cp ${TOOLS_DIR}/docker/compose.yml ${RELEASE_DIR}/
docker compose -f ${RELEASE_DIR}/compose.yml up --force-recreate -d

## Certs
#
while true;do
    printf $warning "------------CERTIFICATE GENERATION--------------\n"

    docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd ${CERT_PATH} && ./makeRootCa.sh --ca-name ${TAK_ALIAS}-CA"
    if [ $? -eq 0 ];then
        docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd ${CERT_PATH} && ./makeCert.sh ca ${INTERMEDIARY_CA}"
        if [ $? -eq 0 ];then
            docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd ${CERT_PATH} && ./makeCert.sh server ${TAK_ALIAS}"
            if [ $? -eq 0 ];then
                docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "cd ${CERT_PATH} && ./makeCert.sh client ${TAKADMIN}"
                if [ $? -eq 0 ];then
                    break
                fi
            fi
        fi
    fi
    sleep 10
done

sleep 30

while true; do
    docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar usermod -A -p \"${TAKADMIN_PASS}\" ${TAKADMIN}"
    if [ $? -eq 0 ];then
        docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar certmod -A ${CERT_PATH}/files/${TAKADMIN}.pem"
        if [ $? -eq 0 ];then
            break
        fi
    fi
    sleep 10
done

docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "useradd $USER && chown -R $USER:$USER ${CERT_PATH}/"
docker compose -f ${RELEASE_DIR}/compose.yml stop tak-server
docker compose -f ${RELEASE_DIR}/compose.yml start tak-server


printf $warning "\n\nImport the $TAKADMIN.p12 certificate from this folder to your browser as per the README.md file\n"
printf $success "Login at https://$URL:8443 with your admin account. No need to run the /setup step as this has been done.\n"
printf $info "Certificates and *CERT DATA PACKAGES* are in tak/certs/files \n\n"

printf $info "Execute into running container 'docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash' \n\n"

printf $danger "---------PASSWORDS----------------\n\n"
printf $danger "Tak Admin user      : $TAKADMIN\n"
printf $danger "Tak Admin password  : $TAKADMIN_PASS\n"
printf $danger "PostgreSQL password : $PG_PASS\n\n"
printf $danger "---------PASSWORDS----------------\n\n"
