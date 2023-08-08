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
if [[ "$arch" == *"arm"* ]];then
    DOCKER=docker.io
fi

sudo apt -y update
sudo apt -y install \
    git \
    openjdk-${JDK_VERSION}-jre-headless \
    net-tools \
    pwgen \
    libxml2-utils \
    qrencode\
    ufw \
    unzip \
    vim \
    wget \
    zip

# Firewall Rules
#
printf $info "\nAllow 22 [SSH]\n"
sudo ufw allow OpenSSH
echo
sudo ufw enable
printf $warning "\n\n------------ Current Firewall Rules ------------\n\n"
sudo ufw status verbose

echo
pause

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

HW=$(uname -m)
if [[ $HW == "armv71" ]];then
    HW=armv7
fi
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s | tr '[A-Z]' '[a-z]')-${HW}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


printf $info "\n\nYou can install TAK with any user that has 'sudo' and can run 'docker' without sudo\n\n"
read -p "Do you want to make a TAK service user [y/n]? " MAKEUSER

if [[ ${MAKEUSER} =~ ^[Yy]$ ]];then
    printf $warning "\n\n------------ Creating Tak Service User ------------\n\n"
    PASS_OMIT="<>/\'\`\""
    TAKUSER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 15)

    sudo adduser --disabled-password --gecos GECOS $TAKUSER
    echo "$TAKUSER:$TAKUSER_PASS" | sudo chpasswd
    sudo usermod -aG sudo $TAKUSER
    sudo usermod -aG docker $TAKUSER

    printf $success "\n\nCreated user: ${TAKUSER}\n"
    printf $success "Password    : ${TAKUSER_PASS}\n\n"

    printf $info "Switch to the ${TAKUSER} [su - ${TAKUSER}] and run the 'opt/tak-tools/scripts/docker/setup.sh' script\n\n"
fi
