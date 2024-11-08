#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
source ${SCRIPT_PATH}/functions.inc.sh 

install_init

if [[ "${OS}" == "linux" ]];then
    msg $warn "\n-------- Installing Docker Dependencies --------\n"

    sudo apt -y update
    sudo apt -y install \
        apache2-utils \
        certbot \
        git \
        iptables-persistent \
        libxml2-utils \
        net-tools \
        nano \
        network-manager \
        openssh-server \
        pwgen \
        qrencode\
        ufw \
        unzip \
        uuid-runtime \
        vim \
        wget \
        zip

    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections

    msg $warn "\n\n------------ Installing Docker ------------\n"

    sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" < /dev/null
    sudo apt-cache policy docker-ce
    sudo apt -y install docker.io
    sudo touch /etc/docker/daemon.json
    sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.${NOW}.tak.install

    ## iptables:
    #     if ufw/other is managing the firewall, this should be set to false
    IPTABLES="false"
    if sudo ufw status | grep -q "inactive"; then
        IPTABLES="true"
    fi 
    echo "{ \"iptables\" : ${IPTABLES} }" > /etc/docker/daemon.json

    HW=$(uname -m)
    if [[ $HW == "armv71" ]];then
        HW=armv7
    fi
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s | tr '[A-Z]' '[a-z]')-${HW}" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    sudo systemctl restart docker
    sudo systemctl enable docker

    if [[ "${IPTABLES}" == "true" ]];then 
        msg $warn "\n-------- Docker set to manage firewall rules --------\n"
    else 
        msg $warn "\n-------- Docker not set to manage firewall rules --------\n"
    fi
else 
    msg $warn "\n-------- Dependency script only meant for ubuntu --------\n"
fi
