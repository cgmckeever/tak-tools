#!/bin/bash

if ! compgen -G "${1}" > /dev/null; then
    printf $warning "\n\n------------ No TAK Server Package found in ${1} ------------\n\n"
    exit
fi

echo; echo
HOSTNAME=${HOSTNAME//\./-}
read -p "Alias of this Tak Server: Default [${HOSTNAME}] : " TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-${HOSTNAME}}
TAK_CA=${TAK_ALIAS}-Intermediary-CA-01

echo; echo
ip link show
echo; echo
DEFAULT_NIC=$(route | grep default | awk 'NR==1{print $8}')
read -p "Which Network Interface? Default [${DEFAULT_NIC}] : " NIC
NIC=${NIC:-${DEFAULT_NIC}}

IP=$(ip addr show $NIC | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)
URL=$IP

echo; echo
printf $warning "Answering [y]es to the next prompt will restrict access to a VPN network.\n\n"
read -p "Is the TAK Server behind a VPN [Y/n]? " VPN
VPN=${VPN:-y}

TRAFFIC_SOURCE="0.0.0.0/0"
if [[ ${VPN} =~ ^[Yy]$ ]];then
    IFS='.' read A B C D <<< ${IP}
    TRAFFIC_SOURCE=${A}.${B}.${C}.0/24

    echo; echo
    read -p "VPN Traffic Range [${VPN_RANGE}]: " TRAFFIC_SOURCE
    TRAFFIC_SOURCE=${TRAFFIC_SOURCE:-${VPN_RANGE}}
fi

printf $warning "\n\n------------ Certificate Subject Info --------------\n\n"

printf $warning "------------ SSL setup. Hit enter (x4) to accept the defaults ------------\n\n"

read -p "State (for cert generation). Default [state] : " STATE
export STATE=${STATE:-state}

read -p "City (for cert generation). Default [city] : " CITY
export CITY=${CITY:-city}

read -p "Organization Name (for cert generation) Default [TAK] : " ORGANIZATION
export ORGANIZATION=${ORGANIZATION:-TAK}

read -p "Organizational Unit (for cert generation). Default [${ORGANIZATION}] : " ORGANIZATIONAL_UNIT
export ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-${ORGANIZATION}}