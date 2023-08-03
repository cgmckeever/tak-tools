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

CAPASS="atakatak"
CERTPASS="atakatak"
DOCKER_SUBNET="172.20.0.0/24"
TAK_COT_PORT=8089

WORK_DIR=~/tak-server
sudo rm -rf $WORK_DIR
mkdir -p $WORK_DIR

RELEASE_DIR="${WORK_DIR}/release"
TAK_DIR="${RELEASE_DIR}/tak"
CERT_DIR="${TAK_DIR}/certs"

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TOOLS_DIR=$(dirname $(dirname $SCRIPT_DIR))
TEMPLATE_DIR="${TOOLS_DIR}/templates"

TAK_PATH="/opt/tak"
CERT_PATH="${TAK_PATH}/certs"

printf $warning "\n\n------------ Unpacking Docker Release ------------\n\n"

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

printf $warning "\n\n------------ Updating UFW Firewall Rules ------------\n\n"

printf $info "\nAllow 8089v [API]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8089
printf $info "\nAllow 8443 [certificate auth]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8443
printf $info "\nAllow 8446 [user/pass auth]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8446
printf $info "\nAllow 9000 [federation]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 9000
printf $info "\nAllow 9001 [federation]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 9001
printf $info "\nAllow Docker 5432 [postgres]\n"
sudo ufw allow proto tcp from ${DOCKER_SUBNET} to any port 5432
sudo ufw route allow from ${DOCKER_SUBNET} to ${DOCKER_SUBNET}

printf $warning "\n\n------------ SSL setup. Hit enter (x4) to accept the defaults ------------\n\n"
## Set variables for generating CA and client certs
#

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
printf $warning "\n\n------------ Updating CoreConfig.xml ------------\n\n"

cp ${TEMPLATE_DIR}/CoreConfig-${VERSION}.xml.tmpl ${TAK_DIR}/CoreConfig.xml

SSL_CERT_INFO=""
if [[ -f ~/letsencrypt.txt ]]; then
    printf $info "\nUsing LetsEncrypt Certificate\n"
    FQDN=$(cat ~/letsencrypt.txt)
    URL=$FQDN
    CERT_NAME=le-${FQDN//\./-}
    LE_DIR="/etc/letsencrypt/live/$FQDN"
    mkdir -p ${CERT_DIR}/letsencrypt

    sudo openssl pkcs12 -export \
        -in ${LE_DIR}/fullchain.pem \
        -inkey ${LE_DIR}/privkey.pem \
        -name ${CERT_NAME} \
        -out ${CERT_DIR}/letsencrypt/${CERT_NAME}.p12 \
        -passout pass:${CAPASS}

    sudo keytool -importkeystore \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -destkeystore ${CERT_DIR}/letsencrypt/${CERT_NAME}.jks \
        -srckeystore ${CERT_DIR}/letsencrypt/${CERT_NAME}.p12 \
        -srcstoretype PKCS12

    sudo keytool -import \
        -noprompt \
        -alias bundle \
        -trustcacerts \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -file ${LE_DIR}/fullchain.pem \
        -keystore ${CERT_DIR}/letsencrypt/${CERT_NAME}.jks

    SSL_CERT_INFO="keystore=\"JKS\" keystoreFile=\"${CERT_PATH}/letsencrypt/${CERT_NAME}.jks\" keystorePass=\"__CAPASS\" truststore=\"JKS\" truststoreFile=\"${CERT_PATH}/files/truststore-__TRUSTSTORE.jks\" truststorePass=\"__CAPASS\""
fi

sed -i "s#__SSL_CERT_INFO#${SSL_CERT_INFO}#g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__CAPASS/${CAPASS}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__ORGANIZATION/${ORGANIZATION}/g" ${TAK_DIR}/CoreConfig.xml
TRUSTSTORE=${INTERMEDIARY_CA}
sed -i "s/__TRUSTSTORE/${TRUSTSTORE}/g" ${TAK_DIR}/CoreConfig.xml

SIGNING_KEY=${INTERMEDIARY_CA}-signing
sed -i "s/__SIGNING_KEY/${SIGNING_KEY}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__CRL/${__INTERMEDIARY_CA}/g" ${TAK_DIR}/CoreConfig.xml

sed -i "s/__TAK_ALIAS/${TAK_ALIAS}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__HOSTIP/${URL}/g" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__PG_PASS/${PG_PASS}/" ${TAK_DIR}/CoreConfig.xml
sed -i "s/__TAK_COT_PORT/${TAK_COT_PORT}/" ${TAK_DIR}/CoreConfig.xml

# Better memory allocation:
# By default TAK server allocates memory based upon the *total* on a machine.
# Allocate memory based upon the available memory so this still scales
#
sed -i "s/MemTotal/MemFree/g" ${TAK_DIR}/setenv.sh


printf $warning "\n\n------------ Creating ENV variable file ------------\n\n"
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
TRUSTSTORE=$TRUSTSTORE
URL=$URL
TAK_COT_PORT=$TAK_COT_PORT
IP=$IP
EOF

printf $warning "\n\n------------ Building Docker Containers ------------\n\n"
cp ${TOOLS_DIR}/docker/compose.yml ${RELEASE_DIR}/
docker compose -f ${RELEASE_DIR}/compose.yml up --force-recreate -d

printf $warning "\n\n------------ Certificate Generation --------------\n\n"
printf $info "If prompted to replace certificate, enter Y\n"
read -p "Press any key to resume setup... "
## Certs
#
while true;do
    printf $info "\n------------ Generating --------------\n"

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

printf $warning "\n\n------------ Waiting for Server to start --------------\n\n"
sleep 45

printf $warning "\n\n------------ Create Admin User --------------\n\n"
printf $info "You may see several JAVA warnings. This is expected.\n\n"

while true; do
    printf $info "\n------------ Creating --------------\n"

    docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar usermod -A -p \"${TAKADMIN_PASS}\" ${TAKADMIN}"
    if [ $? -eq 0 ];then
        docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "java -jar ${TAK_PATH}/utils/UserManager.jar certmod -A ${CERT_PATH}/files/${TAKADMIN}.pem"
        if [ $? -eq 0 ];then
            break
        fi
    fi
    sleep 10
done

printf $warning "\n\n------------ Configuration Complete. Restarting --------------\n\n"

docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash -c "useradd $USER && chown -R $USER:$USER ${CERT_PATH}/"
docker compose -f ${RELEASE_DIR}/compose.yml restart tak-server


printf $info "Certificates and *CERT DATA PACKAGES* are in tak/certs/files \n\n"
printf $warning "\n\nImport the ${CERT_PATH}/files/$TAKADMIN.p12 certificate to your browser as per the README\n\n"

printf $success "Login at https://$URL:8443 with your admin account. No need to run the /setup step as this has been done.\n\n"

INFO=${RELEASE_DIR}/info.txt
echo "---------PASSWORDS----------------" > ${INFO}
echo >> ${INFO}
echo "Tak Admin user      : $TAKADMIN" >> ${INFO}
echo "Tak Admin password  : $TAKADMIN_PASS" >> ${INFO}
echo "PostgreSQL password : $PG_PASS" >> ${INFO}
echo >> ${INFO}
echo "---------PASSWORDS----------------" >> ${INFO}
printf $danger "$(cat ${INFO})"

printf $warning "\nMAKE A NOTE OF YOUR PASSWORDS. THEY WON'T BE SHOWN AGAIN.\n\n
"
printf $warning "You have a database listening on TCP 5432 which requires a login. You should still block this port with a firewall\n\n"

printf $info "Docker containers should automatically start with the Docker service from now on.\n"
printf $info "Execute into running container 'docker compose -f ${RELEASE_DIR}/compose.yml exec tak-server bash' \n\n"