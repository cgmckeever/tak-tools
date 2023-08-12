#!/bin/bash

if ! compgen -G "${1}" > /dev/null; then
    printf $warning "\n\n------------ No TAK Server Package found in ${1} ------------\n\n"
    exit
fi

echo; echo
HOSTNAME=${HOSTNAME//\./-}
read -p "Alias of this Tak Server: Default [${HOSTNAME}] : " TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-${HOSTNAME}}

echo; echo
ip link show
echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}')
read -p "Which Network Interface? Default [${DEFAULT_NIC}] : " NIC
NIC=${NIC:-${DEFAULT_NIC}}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)
URL=$IP

echo; echo
read -p "Is the TAK Server behind a VPN [Y/n]? " VPN
VPN=${VPN:-y}

TRAFFIC_SOURCE=${IP}/24
if [[ ${VPN} =~ ^[Nn]$ ]];then
    TRAFFIC_SOURCE="0.0.0.0/0"
fi