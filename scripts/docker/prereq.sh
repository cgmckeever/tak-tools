#!/bin/bash

# prereq
#
sudo apt -y update
sudo apt -y install \
    git \
    net-tools \
    pwgen \
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

TAKUSER=tak
TAKUSER_PASS=nopass #$(pwgen -cvy1 25)

sudo adduser --disabled-password --gecos GECOS $TAKUSER
sudo usermod -aG sudo $TAKUSER
sudo usermod -aG docker $TAKUSER

sudo -H -u tak bash -c 'git config --global safe.directory /opt/tak-tools'
