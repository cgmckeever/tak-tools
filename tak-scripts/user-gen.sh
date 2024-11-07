#!/bin/bash

source /opt/tak/tak-tools/functions.inc.sh tak
TAK_CONF_PATH=/opt/tak/tak-tools/conf

cd /opt/tak/certs
CLIENT_PATH=files/clients/${1}
mkdir -p ${CLIENT_PATH}

msg $info "\nCreate User: ${1}"
msg $info "echo Password: ${2}\n"

java -jar /opt/tak/utils/UserManager.jar usermod ${3} -p "${2}" ${1}

./makeCert.sh client ${1}

if [ "$3" = "-A" ]; then
    msg $info "\n\nModify ${1} certificate to ADMIN role\n"
	java -jar /opt/tak/utils/UserManager.jar certmod -A /opt/tak/certs/files/${1}.pem
fi 

UUID="${1}$(date +%s)"

msg $info "Creating ${1} cert bundle ${CLIENT_PATH}/"

sed -e "s/__UUID/${UUID}/g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    -e "s/__USERNAME/${1}/g" \
    ${TAK_CONF_PATH}/manifest.client.xml.tmpl > ${CLIENT_PATH}/manifest.xml

sed -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_URI/${TAK_URI}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/g" \
    -e "s/__CA_PASS/${CA_PASS}/g" \
    -e "s/__CERT_PASS/${CERT_PASS}/g" \
    -e "s/__TRUSTSTORE/${TAK_CA_FILE}-bundle/g" \
    -e "s/__USERNAME/${1}/g" \
    ${TAK_CONF_PATH}/server.client.pref.tmpl > ${CLIENT_PATH}/server.pref