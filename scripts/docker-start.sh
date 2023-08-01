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

# Docker
#
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-cache policy docker-ce
sudo apt -y install docker-ce
echo { "iptables" : false } >> /etc/docker/daemon.json

sudo systemctl restart docker
sudo systemctl enable docker

sudo curl -L "https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

TAKUSER=tak

sudo adduser --disabled-password --gecos GECOS $TAKUSER
sudo usermod -aG sudo $TAKUSER
sudo usermod -aG docker $TAKUSER

# Change to TAK user
#
su - $TAKUSER

WORK_DIR=~/tak-server
rm -rf $WORK_DIR
mkdir -p $WORK_DIR

unzip /tmp/takserver*.zip -d ${$WORK_DIR}/; \
mv tak-server/tak* ${$WORK_DIR}/release;
chown -R $USER:$USER ${$WORK_DIR}


TAKADMIN=tak-admin
TAKADMIN_PASS=$(pwgen -cvy1 25)

PG_PASS=$(pwgen -cvy1 25)

DEFAULT_NIC=$(route | grep default | awk '{print $8}')