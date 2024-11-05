#!/bin/bash

source /opt/tak/tak-tools/config.inc.sh
CONF_PATH=/opt/tak/tak-tools/conf

cd /opt/tak/certs
CLIENT_PATH=files/clients/${1}
mkdir -p ${CLIENT_PATH}

echo Create User: ${1}
echo Password: ${2}
echo
java -jar /opt/tak/utils/UserManager.jar usermod ${3} -p "${2}" ${1}

./makeCert.sh client ${1}

if [ "$3" = "-A" ]; then
    echo; echo 
	echo Modify ${1} certificate to ADMIN role
	java -jar /opt/tak/utils/UserManager.jar certmod -A /opt/tak/certs/files/${1}.pem
fi 

UUID="${1}$(date +%s)"

echo "Creating ${1} cert bundle ${CLIENT_PATH}/"

sed -e "s/__UUID/${UUID}/g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    -e "s/__USERNAME/${1}/g" \
    ${CONF_PATH}/manifest.client.xml.tmpl > ${CLIENT_PATH}/manifest.xml

sed -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/g" \
    -e "s/__CA_PASS/${CA_PASS}/g" \
    -e "s/__CERT_PASS/${CERT_PASS}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    -e "s/__USERNAME/${1}/g" \
    ${CONF_PATH}/server.client.pref.tmpl > ${CLIENT_PATH}/server.pref