#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/inc/functions.sh 
source ${SCRIPT_PATH}/inc/configure.sh 

install_init

## Inputs
#
CONFIG_TMPL="config.inc.example.sh"
source ${SCRIPT_PATH}/inc/inputs.sh

## TAK-Tools Config
#
RELEASE_PATH=${ROOT_PATH}/release/${TAK_ALIAS}
mkdir -p ${RELEASE_PATH}

sed -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
	-e "s/__TAK_URI/${TAK_URI}/g" \
	-e "s/__INSTALLER/${INSTALLER}/g" \
	-e "s/__VERSION/$VERSION/g" \
	-e "s/__TAK_DB_ALIAS/$TAK_DB_ALIAS/g" \
	-e "s/__TAK_DB_PASS/${TAK_DB_PASS}/g" \
	-e "s/__CA_PASS/${CA_PASS}/g" \
	-e "s/__CERT_PASS/${CERT_PASS}/g" \
	-e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
	-e "s/__ORGANIZATION/${ORGANIZATION}/g" \
	-e "s/__CITY/${CITY}/g" \
	-e "s/__STATE/${STATE}/g" \
	-e "s/__COUNTRY/${COUNTRY}/g" \
	-e "s/__CLIENT_VALID_DAYS/${CLIENT_VALID_DAYS}/g" \
	-e "s/__LE_ENABLE/${LE_ENABLE}/g" \
	-e "s/__LE_EMAIL/${LE_EMAIL}/g" \
	-e "s/__LE_VALIDATOR/${LE_VALIDATOR}/g" \
	${CONFIG_TMPL} > ${RELEASE_PATH}/config.inc.sh

info ${RELEASE_PATH} "---- TAK Info: ${TAK_ALIAS} ----" init
info ${RELEASE_PATH} "Install: ${INSTALLER}"
info ${RELEASE_PATH} "TAK Version: ${VERSION}"
info ${RELEASE_PATH} "TAK Pack: $(basename ${TAK_PACKAGE})"
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Hostname/URI: ${TAK_URI}" 
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Database Info:"
info ${RELEASE_PATH} "  URI: ${TAK_DB_ALIAS}" 
info ${RELEASE_PATH} "  User: martiuser" 
info ${RELEASE_PATH} "  Password: ${TAK_DB_PASS}" 
info ${RELEASE_PATH} ""

msg $warn "\nUpdate the config: ${RELEASE_PATH}/config.inc.sh"

prompt "Do you want to inline edit the conf with vi [y/N]?" EDIT_CONF
if [[ ${EDIT_CONF} =~ ^[Yy]$ ]];then
	vi ${RELEASE_PATH}/config.inc.sh
fi