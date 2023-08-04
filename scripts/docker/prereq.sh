#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/scripts/shared.inc.sh

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
sudo ufw enable
sudo ufw status

pause

printf $warning "\n\n------------ Installing Docker ------------\n\n"
# Docker
#

sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-cache policy docker-ce
sudo apt -y install docker-ce
echo '{ "iptables" : false }' >> /etc/docker/daemon.json

sudo systemctl restart docker
sudo systemctl enable docker

sudo curl -L "https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


printf $warning "\n\n------------ Creating Tak Service User ------------\n\n"
TAKUSER=tak
PASS_OMIT="<>/\'\`\""
TAKUSER_PASS=$(pwgen -cvy1 -r ${PASS_OMIT} 15)

sudo adduser --disabled-password --gecos GECOS $TAKUSER
echo "$TAKUSER:$TAKUSER_PASS" | sudo chpasswd
sudo usermod -aG sudo $TAKUSER
sudo usermod -aG docker $TAKUSER

printf $success "\n\nCreated user: ${TAKUSER}\n"
printf $success "Password    : ${TAKUSER_PASS}\n\n"

sudo -H -u tak bash -c 'git config --global safe.directory /opt/tak-tools'

printf $info "Switch to the ${TAKUSER} [su - ${TAKUSER}] and run the 'opt/tak-tools/scripts/docker/setup.sh' script\n\n"
