#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh
source ${SCRIPT_PATH}/config.inc.sh

# =======================

## Set inputs
#
cd ${PACKAGE_PATH}/
PACKAGE=$(ls takserver*.deb)
VERSION=$(echo ${PACKAGE} | sed 's/takserver_\(.*\)-RELEASE.*/\1/')
source ${TAK_SCRIPT_PATH}/v1/inputs.inc.sh ${PACKAGE}

## Set firewall rules
#
source ${TAK_SCRIPT_PATH}/v1/firewall-update.inc.sh ${TRAFFIC_SOURCE}
pause

## CoreConfig
#  Must come before install as DB update will look for config
#
sudo rm -rf ${TAK_PATH}/
sudo mkdir -p ${TAK_PATH}/certs/files/clients
source ${TAK_SCRIPT_PATH}/v1/coreconfig.inc.sh "127.0.0.1"

printf $warning "\n\n------------ Unpacking TAK Installer ------------\n\n"
sudo apt install -y ./${PACKAGE}

## Strange 4.8 error
#
if [ ! -f /usr/bin/systemctl ]; then
    sudo ln -s /bin/systemctl /usr/bin/systemctl
fi

## Database Setup
#
DB_SETUP="No"
case ${VERSION} in

  "4.7")
    DB_SETUP="Yes"
    ;;

  "4.8")
    DB_SETUP="Yes"
    ;;
esac

if [[ ${DB_SETUP} == "Yes" ]]; then
    sudo ${TAK_PATH}/db-utils/takserver-setup-db.sh
fi

## Generate Certs
#
sudo chown -R $USER:$USER ${CERT_PATH}
source ${TAK_SCRIPT_PATH}/v1/cert-gen.inc.sh

## User cleanup
#
sudo usermod --shell /bin/bash tak
sudo ln -s ${TAK_SCRIPTS}/ ${TAK_PATH}/tools
sudo chown -R tak:tak ${TAK_PATH}

printf $warning "\n\n------------ Creating ENV variable file  ------------\n\n"

sudo cp ${TEMPLATE_PATH}/tak/standalone/tak.profile.sh.tmpl /etc/profile.d/tak.profile.sh
sudo chmod 755 /etc/profile.d/tak.profile.sh

sudo sed -i \
    -e "s#__TAK_PATH#${TAK_PATH}#g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__TAK_NIC/${NIC}/g" \
    -e "s/__TAK_CAPASS/${CAPASS}/g" \
    -e "s/__TAK_PASS/${CERTPASS}/g" \
    -e "s/__TAK_CA/${TAK_CA}/g" \
    -e "s/__TAK_COUNTRY/${COUNTRY}/g" \
    -e "s/__TAK_STATE/${STATE}/g" \
    -e "s/__TAK_CITY/${CITY}/g" \
    -e "s/__TAK_ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
    -e "s/__TAK_ORGANIZATION/${ORGANIZATION}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/" \
    -e "s/__TAK_IP/${IP}/g" \
    -e "s/__TAK_URL/${URL}/" /etc/profile.d/tak.profile.sh

cat /etc/profile.d/tak.profile.sh

echo; echo
read -p "Do you want to configure TAK Server auto-start [y/n]? " AUTOSTART
sudo cp ${TEMPLATE_PATH}/tak/standalone/tak.tmpl /etc/sudoers.d/tak
sudo systemctl daemon-reload

if [[ $AUTOSTART =~ ^[Yy]$ ]]; then
    sudo systemctl enable takserver
    printf $info "\nTAK Server auto-start enabled\n\n"
else
    printf $info "\nTAK Server auto-start disabled\n\n"
fi

printf $info "------------ Restarting TAK Server ------------\n"
sudo systemctl restart takserver

## Check Server Status
#
source ${TAK_SCRIPT_PATH}/v1/server-check.inc.sh

printf $warning "------------ Create Admin --------------\n\n"
TAKADMIN_PASS=${PAD1}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD2}
while true;do
    printf $info "------------ Enabling Admin User [password and certificate] --------------\n"
    ## printf $info "You may see several JAVA warnings. This is expected.\n\n"
    ## This is where things get sketch, as the the server needs to be up and happy
    ## or everything goes sideways
    #
    sudo java -jar /opt/tak/utils/UserManager.jar usermod -A -p "${TAKADMIN_PASS}" ${TAKADMIN}
    if [ $? -eq 0 ]; then
        sudo java -jar /opt/tak/utils/UserManager.jar certmod -A /opt/tak/certs/files/${TAKADMIN}.pem
        if [ $? -eq 0 ]; then
            break
        fi
    fi
    sleep 10
done

## This should be fixed - script uses the ENV variable name
TAK_URL=${URL}
source ${TAK_SCRIPT_PATH}/v1/autoenroll-data-package.inc.sh

printf $success "\n\n----------------- Installation Complete -----------------\n\n"

## Installation Summary
#
source ${TAK_SCRIPT_PATH}/v1/summary.inc.sh ${TAK_PATH}

