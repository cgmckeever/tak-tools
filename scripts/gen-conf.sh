#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/inc/functions.sh 
source ${SCRIPT_PATH}/inc/configure.sh 

install_init

## TAK-Tools Config
#
RELEASE_PATH=${ROOT_PATH}/release/${TAK_ALIAS}
mkdir -p ${RELEASE_PATH}

if [ -f "${RELEASE_PATH}/config.inc.sh" ]; then
    msg $warn "${RELEASE_PATH}/config.inc.sh exists"
    read -p "n\Do you want to overwrite it? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        msg $warn "\nRebuilding configuration"

        ## Inputs
		#
		CONFIG_TMPL="config.inc.example.sh"
		source ${SCRIPT_PATH}/inc/inputs.sh

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

		msg $warn "\nUpdated the config: ${RELEASE_PATH}/config.inc.sh"

    else
        msg $warn "\nUsing existing config."
    fi
fi

prompt "Do you want to inline edit the conf with vi [y/N]?" EDIT_CONF
if [[ ${EDIT_CONF} =~ ^[Yy]$ ]];then
	vi ${RELEASE_PATH}/config.inc.sh
fi