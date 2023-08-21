#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

# prereq
#
case $(lsb_release -r -s) in
  "20.04")
    JDK_VERSION=16
    ;;
  "22.04")
    JDK_VERSION=19
    ;;
esac

DOCKER=docker-ce
if [[ "$arch" == *"arm"* ]]; then
    DOCKER=docker.io
fi

sudo apt -y update
sudo apt -y install \
    git \
    iptables-persistent \
    openjdk-${JDK_VERSION}-jre-headless \
    net-tools \
    pwgen \
    libxml2-utils \
    nano \
    network-manager \
    qrencode\
    ufw \
    unzip \
    uuid-runtime \
    vim \
    wget \
    zip

echo; echo
## Network Manager
#
read -p "Allow Network Manager to manage Wifi [Y/n]? " NETMAN
if [[ ${NETMAN} =~ ^[Yy]$ ]]; then
    printf $warning "\n\n------------ Installing Network Manager ------------\n\n"
    sudo systemctl start NetworkManager.service
    sudo systemctl enable NetworkManager.service
    sudo sed -i \
    -e "s/networkd/NetworkManagerg" /etc/netplan/50-cloud-init.yaml
    sudo netplan apply
fi

printf $warning "\n\n------------ Installing Docker ------------\n\n"
# Docker
#
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-cache policy docker-ce
sudo apt -y install $DOCKER
sudo touch /etc/docker/daemon.json
sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.$(date "+%Y.%m.%d-%H.%M.%S").tak.install
echo '{ "iptables" : false }' | sudo tee -a /etc/docker/daemon.json

sudo systemctl restart docker
sudo systemctl enable docker

printf $warning "\n\n------------ Updaating FireWall ------------\n\n"
# Firewall Rules
#
printf $info "\nAllow 22 [SSH]\n"
sudo ufw allow OpenSSH
echo
sudo ufw enable
printf $warning "\n\n------------ Current Firewall Rules ------------\n\n"
sudo ufw status verbose
printf $info "\nAllow Allow Docker Outbound \n"
# https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/
DOCKER_HOST_IP=$(docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')
sudo sed -i -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
sudo iptables -t nat -A POSTROUTING ! -o docker0 -s ${DOCKER_HOST_IP} -j MASQUERADE
sudo iptables-save > /etc/iptables/rules.v4
echo
pause

HW=$(uname -m)
if [[ $HW == "armv71" ]]; then
    HW=armv7
fi
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s | tr '[A-Z]' '[a-z]')-${HW}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


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

    printf $success "\n\nCreated user: ${TAKUSER}\n"
    printf $success "Password    : ${TAKUSER_PASS}\n\n"

    printf $info "Switch to the ${TAKUSER} [su - ${TAKUSER}] and run the 'opt/tak-tools/scripts/docker/setup.sh' script\n\n"
fi
