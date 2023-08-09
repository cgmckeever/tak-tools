#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh
source ${SCRIPT_PATH}/config.inc.sh

# =======================

## Set inputs
#
source ${TAK_SCRIPT_PATH}/v1/inputs.inc.sh "release/takserver*.deb"
mkdir -p $WORK_DIR

PACKAGE=$(ls release/takserver*.deb)
VERSION=$(echo ${PACKAGE} | sed 's/release\/takserver_\(.*\)-RELEASE.*/\1/')
cd release/
PACKAGE=$(ls takserver*.deb)
sudo apt install -y ./${PACKAGE}
sudo chown -R $USER:$USER ${TAK_PATH}

## Database Setup
#
if [ -f /opt/tak/db-utils/takserver-setup-db.sh ]; then
    ## Strange 4.8 error
    sudo ln -s /bin/systemctl /usr/bin/systemctl
    sudo systemctl stop takserver
    sudo ${TAK_PATH}/db-utils/takserver-setup-db.sh
fi

## Set variables for generating CA and client certs
#
source ${TAK_SCRIPT_PATH}/v1/ca-vars.inc.sh

## CoreConfig
#
source ${TAK_SCRIPT_PATH}/v1/coreconfig.inc.sh $IP


printf $warning "\n\n------------ Creating ENV variable file  ------------\n\n"

sudo cp ${TEMPLATE_PATH}/tak/standalone/tak.profile.sh.tmpl /etc/profile.d/tak.profile.sh
sudo chmod 755 /etc/profile.d/tak.profile.sh

sudo sed -i \
    -e "s#__TAK_PATH#${TAK_PATH}#g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__NIC/${NIC}/g" \
    -e "s/__CAPASS/${CAPASS}/g" \
    -e "s/__PASS/${CERTPASS}/g" \
    -e "s/__TAK_CA/${TAK_CA}/g" \
    -e "s/__TAK_CITY/${TAK_CA}/g" \
    -e "s/__TAK_STATE/${TAK_STATE}/g" \
    -e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
    -e "s/__ORGANIZATION/${ORGANIZATION}/g" \
    -e "s/__TAK_IP/${IP}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/" \
    -e "s/__TAK_URL/${URL}/" /etc/profile.d/tak.profile.sh

cat /etc/profile.d/tak.profile.sh

## Generate Certs
#
source ${TAK_SCRIPT_PATH}/v1/cert-gen.inc.sh

printf $info "\n\n------------ Restarting TAK Server ------------\n\n"
sudo systemctl daemon-reload
sudo systemctl restart takserver
ln -s ${TAK_PATH}/logs ${WORK_DIR}/logs

echo; echo
read -p "Do you want to configure TAK Server auto-start [y/n]? " AUTOSTART

if [[ $AUTOSTART =~ ^[Yy]$ ]];then
    sudo systemctl enable takserver
    printf $info "\nTAK Server auto-start enabled\n\n"
else
    printf $info "\nTAK Server auto-start disabled\n\n"
fi

## Check Server Status
#
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh

printf $warning "------------ Create Admin --------------\n\n"
## TODO

## Installation Summaary
#
source ${TAK_SCRIPT_PATH}/v1/summary.inc.sh



