#!/bin/bash

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

printf $info "\n-------- Installing Docker Dependencies --------\n\n"

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

sudo apt -y update
sudo apt -y install \
    apache2-utils \
    git \
    iptables-persistent \
    openjdk-${JDK_VERSION}-jre-headless \
    net-tools \
    pwgen \
    libxml2-utils \
    nano \
    network-manager \
    openssh-server \
    qrencode\
    ufw \
    unzip \
    uuid-runtime \
    vim \
    wget \
    zip

printf $warning "\n\n------------ Installing Docker ------------\n\n"
# Docker
#
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-cache policy docker-ce
sudo apt -y install $DOCKER
sudo touch /etc/docker/daemon.json
sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.${NOW}.tak.install
echo '{ "iptables" : false }' | sudo tee -a /etc/docker/daemon.json

HW=$(uname -m)
if [[ $HW == "armv71" ]]; then
    HW=armv7
fi
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s | tr '[A-Z]' '[a-z]')-${HW}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo systemctl restart docker
sudo systemctl enable docker

printf $warning "\n\n------------ Updating FireWall ------------\n\n"
# Firewall Rules
#
printf $info "\nAllow 22 [SSH]\n"
sudo ufw allow OpenSSH
echo
sudo ufw enable
printf $warning "\n\n------------ Current Firewall Rules ------------\n\n"
sudo ufw status verbose
printf $info "\nAllowing Allow Docker Outbound \n"
# https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/
DOCKER_HOST_IP=$(sudo docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')
sudo sed -i -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
sudo iptables -t nat -A POSTROUTING ! -o docker0 -s ${DOCKER_HOST_IP} -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
pause