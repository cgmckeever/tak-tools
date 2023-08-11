#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh
source ${SCRIPT_PATH}/config.inc.sh

# =======================

## Set inputs
#
source ${TAK_SCRIPT_PATH}/v1/inputs.inc.sh "release/takserver*.deb"
mkdir -p $WORK_DIR

## Set firewall rules
#
source ${TAK_SCRIPT_PATH}/v1/firewall.inc.sh
pause

printf $warning "\n\n------------ Unpacking TAK Installer ------------\n\n"
cd release/
PACKAGE=$(ls takserver*.deb)
VERSION=$(echo ${PACKAGE} | sed 's/takserver_\(.*\)-RELEASE.*/\1/')
sudo apt install -y ./${PACKAGE}

## Strange 4.8 error
#
sudo ln -s /bin/systemctl /usr/bin/systemctl

## Generate Certs
#
source ${TAK_SCRIPT_PATH}/v1/cert-gen.inc.sh

## CoreConfig
#
source ${TAK_SCRIPT_PATH}/v1/coreconfig.inc.sh "127.0.0.1"

## Database Setup
#
if [ -f /opt/tak/db-utils/takserver-setup-db.sh ];then
    sudo ${TAK_PATH}/db-utils/takserver-setup-db.sh
fi

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
    -e "s/__CITY/${CITY}/g" \
    -e "s/__STATE/${STATE}/g" \
    -e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
    -e "s/__ORGANIZATION/${ORGANIZATION}/g" \
    -e "s/__IP/${IP}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/" \
    -e "s/__URL/${URL}/" /etc/profile.d/tak.profile.sh

cat /etc/profile.d/tak.profile.sh

echo; echo
read -p "Do you want to configure TAK Server auto-start [y/n]? " AUTOSTART

if [[ $AUTOSTART =~ ^[Yy]$ ]];then
    sudo systemctl enable takserver
    printf $info "\nTAK Server auto-start enabled\n\n"
else
    printf $info "\nTAK Server auto-start disabled\n\n"
fi

printf $info "\n\n------------ Restarting TAK Server ------------"
sudo systemctl daemon-reload
sudo systemctl restart takserver
ln -s ${TAK_PATH}/logs ${WORK_DIR}/logs

## Check Server Status
#
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh

printf $warning "------------ Create Admin --------------\n\n"
TAKADMIN_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}
while true;do
    sudo java -jar /opt/tak/utils/UserManager.jar usermod -A -p "${TAKADMIN_PASS}" ${TAKADMIN}
    if [ $? -eq 0 ];then
        sudo java -jar /opt/tak/utils/UserManager.jar certmod -A /opt/tak/certs/files/${TAKADMIN}.pem
        if [ $? -eq 0 ];then
            break
        fi
    fi
    sleep 10
done

printf $success "\n\n----------------- Installation Complete -----------------\n\n"

## Installation Summary
#
source ${TAK_SCRIPT_PATH}/v1/summary.inc.sh

