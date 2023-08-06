#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh
source ${SCRIPT_PATH}/config.inc.sh

# =======================

sudo rm -rf $WORK_DIR

if ! compgen -G "release/takserver*.zip" > /dev/null; then
    printf $warning "\n\n------------ No TAK Server Package found in ~/release/ ------------\n\n"
    exit
fi

printf $warning "\n\n------------ Unpacking Docker Release ------------\n\n"

unzip ~/release/takserver*.zip -d ~/
mv ~/takserver* ${WORK_DIR}
chown -R $USER:$USER ${WORK_DIR}
VERSION=$(cat ${TAK_PATH}/version.txt | sed 's/\(.*\)-.*-.*/\1/')

echo; echo
HOSTNAME=${HOSTNAME//\./-}
read -p "Alias of this Tak Server: Default [${HOSTNAME}] : " TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-$HOSTNAME}

echo; echo
ip link show
echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}')
read -p "Which Network Interface? Default [${DEFAULT_NIC}] : " NIC
NIC=${NIC:-${DEFAULT_NIC}}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)
URL=$IP

printf $warning "\n\n------------ Updating UFW Firewall Rules ------------\n\n"

printf $info "Allow 22 [SSH]\n"
sudo ufw allow OpenSSH;
printf $info "\nAllow 8089 [API]\n"
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

read -p "City (for cert generation). Default [city] : " CITY
export CITY=${CITY:-city}

read -p "Organization Name (for cert generation) Default [TAK] : " ORGANIZATION
export ORGANIZATION=${ORGANIZATION:-TAK}

read -p "Organizational Unit (for cert generation). Default [${ORGANIZATION}] : " ORGANIZATIONAL_UNIT
export ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-${ORGANIZATION}}

## CoreConfig
#
printf $warning "\n\n------------ Updating CoreConfig.xml ------------\n\n"

cp ${TEMPLATE_PATH}/CoreConfig-${VERSION}.xml.tmpl ${TAK_PATH}/CoreConfig.xml

SSL_CERT_INFO=""
if [[ -f ~/letsencrypt.txt ]]; then
    printf $info "\nUsing LetsEncrypt Certificate\n"
    FQDN=$(cat ~/letsencrypt.txt)
    URL=$FQDN
    CERT_NAME=le-${FQDN//\./-}
    LE_DIR="/etc/letsencrypt/live/$FQDN"
    mkdir -p ${CERT_PATH}/letsencrypt

    sudo openssl pkcs12 -export \
        -in ${LE_DIR}/fullchain.pem \
        -inkey ${LE_DIR}/privkey.pem \
        -name ${CERT_NAME} \
        -out ${CERT_PATH}/letsencrypt/${CERT_NAME}.p12 \
        -passout pass:${CAPASS}

    sudo keytool -importkeystore \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -destkeystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.jks \
        -srckeystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.p12 \
        -srcstoretype PKCS12

    sudo keytool -import \
        -noprompt \
        -alias bundle \
        -trustcacerts \
        -deststorepass ${CAPASS} \
        -srcstorepass ${CAPASS} \
        -file ${LE_DIR}/fullchain.pem \
        -keystore ${CERT_PATH}/letsencrypt/${CERT_NAME}.jks

    printf $info "Setting LetsEncrypt on Port:8446\n\n"
    SSL_CERT_INFO="keystore=\"JKS\" keystoreFile=\"${DOCKER_CERT_PATH}/letsencrypt/${CERT_NAME}.jks\" keystorePass=\"__CAPASS\" truststore=\"JKS\" truststoreFile=\"${DOCKER_CERT_PATH}/files/truststore-__TAK_CA.jks\" truststorePass=\"__CAPASS\""
fi

sed -i "s#__SSL_CERT_INFO#${SSL_CERT_INFO}#g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting Cert Password\n\n"
sed -i "s/__CAPASS/${CAPASS}/g" ${TAK_PATH}/CoreConfig.xml
sed -i "s/__PASS/${CERTPASS}/g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting Organization Info\n\n"
sed -i "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" ${TAK_PATH}/CoreConfig.xml
sed -i "s/__ORGANIZATION/${ORGANIZATION}/g" ${TAK_PATH}/CoreConfig.xml

TAK_CA=${TAK_ALIAS}-Intermediary-CA-01
SIGNING_KEY=${TAK_CA}-signing
printf $info "Setting CA: ${TAK_CA}\n\n"
sed -i "s/__TAK_CA/${TAK_CA}/g" ${TAK_PATH}/CoreConfig.xml
sed -i "s/__SIGNING_KEY/${SIGNING_KEY}/g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting Revocation List: ${TAK_CA}.crl\n\n"
sed -i "s/__CRL/${TAK_CA}/g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting TAK Server Alias: ${TAK_ALIAS}\n\n"
sed -i "s/__TAK_ALIAS/${TAK_ALIAS}/g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting IP/FQDN: ${URL}\n\n"
sed -i "s/__HOSTIP/${URL}/g" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting API Port: ${TAK_COT_PORT}\n\n"
sed -i "s/__TAK_COT_PORT/${TAK_COT_PORT}/" ${TAK_PATH}/CoreConfig.xml

PG_PASS=${PAD2}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD1}
printf $info "Setting PostGres Password: ${PG_PASS}\n\n"
sed -i "s/__PG_PASS/${PG_PASS}/" ${TAK_PATH}/CoreConfig.xml
pause

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

printf $warning "\n\n------------ Certificate Generation --------------\n\n"
printf $info "If prompted to replace certificate, enter Y\n"
pause

## Certs
#
cd ${CERT_PATH}
mkdir -p files
echo "unique_subject=no" > files/crl_index.txt.attr
while true;do
    printf $info "\n------------ Generating Certificates --------------"
    printf $success "\n\n${TAK_ALIAS}-Root-CA-01\n"
    ./makeRootCa.sh --ca-name $root {TAK_ALIAS}-Root-CA-01
    if [ $? -eq 0 ];then
        printf $success "\n\nca ${TAK_CA}\n"
        ./makeCert.sh ca ${TAK_CA}
        if [ $? -eq 0 ];then
            printf $success "\n\nserver ${TAK_ALIAS}\n"
            ./makeCert.sh server ${TAK_ALIAS}
            if [ $? -eq 0 ];then
                printf $success "\n\nclient ${TAKADMIN}\n"
                ./makeCert.sh client ${TAKADMIN}
                if [ $? -eq 0 ];then
                    break
                fi
            fi
        fi
    fi
    sleep 10
done

printf $warning "\n\n------------ Configuration Complete. Starting Containers --------------\n\n"
cp ${TOOLS_PATH}/docker/docker-compose.yml ${WORK_DIR}/

printf $info "------------ Building TAK DB ------------\n\n"
$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml up tak-db -d

printf $info "\n\n------------ Building TAK Server ------------\n\n"
$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml up tak-server -d

ln -s ${TAK_PATH}/logs ${WORK_DIR}/logs

echo; echo
read -p "Do you want to configure TAK Server auto-start [y/n]? " AUTOSTART
cp ${TEMPLATE_PATH}/docker.service.tmpl ${WORK_DIR}/tak-server-docker.service
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

echo; echo
START_TIME="$(date -u +%s)"
while true; do
    printf $warning "------------ Waiting for Server to start --------------\n"
    sleep 30
    RESPONSE=$(curl --insecure -I https://${IP}:8446 2>&1)
    if [ $? -eq 0 ]; then
        END_TIME="$(date -u +%s)"
        printf $success "\n------------ Server Started --------------\n"
        ELAPSED="$((${END_TIME}-${START_TIME}))"
        printf $info "Restart took ${ELAPSED} seconds\n\n"
        break
    fi
done

$DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "useradd $USER && chown -R $USER:$USER \${CERT_PATH}/"

printf $warning "------------ Create Admin --------------\n\n"
## printf $info "You may see several JAVA warnings. This is expected.\n\n"
## This is where things get sketch, as the the server needs to be up and happy
## or everything goes sideways

TAKADMIN_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}

while true; do
    printf $info "\n------------ Enabling Admin User [pass and certificate] --------------\n"

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

# We are done now
#
########################## OUTPUT ##########################
#
#
printf $info "Certificates and *CERT DATA PACKAGES* are in tak/certs/files \n"
printf $warning "Import the ${CERT_PATH}/files/$TAKADMIN.p12 certificate to your browser as per the README\n\n"

printf $success "Login at https://$URL:8443 with your admin account certificate.\n\n"
printf $success "Login at https://$URL:8446 with your admin account user/pass.\n"
printf $success "No need to run the /setup step as this has been done.\n\n"

INFO=${WORK_DIR}/info.txt
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

printf $info "Execute into running container '$DOCKER_COMPOSE -f ${WORKDIR}/docker-compose.yml exec tak-server bash' \n\n"