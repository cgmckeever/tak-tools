#!/bin/bash

color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m      # cyan
color success 92m   # green
color warning 93m   # yellow
color danger 91m    # red

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

sudo adduser --gecos GECOS $TAKUSER
echo "$TAKUSER:$TAKUSER_PASS" | sudo chpasswd
sudo usermod -aG sudo $TAKUSER
sudo usermod -aG docker $TAKUSER

printf $success "Created user: ${TAKUSER}\n"
printf $success "Password    : ${TAKUSER_PASS}\n\n"

sudo -H -u tak bash -c 'git config --global safe.directory /opt/tak-tools'

printf $info "Switch to the ${TAKUSER} [su - ${TAKUSER}] and run the 'opt/tak-tools/scripts/docker/setup.sh' script"
