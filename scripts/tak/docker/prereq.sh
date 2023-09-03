#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

source ${TOOLS_PATH}/scripts/shared/docker-prereq.inc.sh

## Network Manager
#
echo; echo
read -p "Allow Network Manager to manage Wifi [Y/n]? " NETMAN
if [[ ${NETMAN} =~ ^[Yy]$ ]]; then
    printf $warning "\n\n------------ Installing Network Manager ------------\n\n"
    sudo touch /etc/netplan/50-cloud-init.yaml
    sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.${NOW}.install
    sudo systemctl start NetworkManager.service
    sudo systemctl enable NetworkManager.service
    sudo sed -i \
        -e "s/networkd/NetworkManager/g" /etc/netplan/50-cloud-init.yaml
    sudo netplan apply

    sudo cp ${TEMPLATE_PATH}/cloud-init.yaml.tmpl /etc/netplan/50-cloud-init.yaml.wired
    DEFAULT_NIC=$(route | grep default | awk 'NR==1{print $8}')
    sudo sed -i \
        -e "s/__WIRED_NIC/${DEFAULT_NIC}/g" /etc/netplan/50-cloud-init.yaml.wired
fi

printf $info "\n\nYou can install TAK with any user that has 'sudo' and can run 'docker' without sudo\n\n"
read -p "Do you want to make a TAK service user [y/n]? " MAKEUSER

if [[ ${MAKEUSER} =~ ^[Yy]$ ]]; then
    printf $warning "\n\n------------ Creating Tak Service User ------------\n\n"
    TAKUSER=tak
    PASS_OMIT="<>/\'\`\""
    PASS_TEMP=$(pwgen -cvy1 -r ${PASS_OMIT} 15)
    read -p "Enter ${TAKUSER} user password: default [${PASS_TEMP}] " TAKUSER_PASS
    TAKUSER_PASS=${TAKUSER_PASS:-${PASS_TEMP}}

    sudo adduser --disabled-password --gecos GECOS $TAKUSER
    echo "$TAKUSER:$TAKUSER_PASS" | sudo chpasswd
    sudo usermod -aG sudo $TAKUSER
    sudo usermod -aG docker $TAKUSER

    if [[ -f ~/letsencrypt.txt  ]]; then
        sudo cp ~/letsencrypt.txt /home/${TAKUSER}/
    fi

    printf $success "\n\nCreated user: ${TAKUSER}\n"
    printf $success "Password    : ${TAKUSER_PASS}\n\n"

    printf $info "Switch to the ${TAKUSER} [su - ${TAKUSER}] and run the 'opt/tak-tools/scripts/docker/setup.sh' script\n\n"
fi
