#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
export ROOT_PATH=$(realpath ${SCRIPT_PATH}/../..)

source ${ROOT_PATH}/scripts/functions.inc.sh 

if [[ "${OS}" == "linux" ]];then
	msg $warn "\n-------- Installing Ubuntu Dependencies --------\n"

	# Check the version
	#
	version=$(lsb_release -rs)
	if [[ "$version" != "20.04" &&  "$version" != "22.04" ]]; then
	    msg $info "\nFound Ubuntu ${version}\n"
	    msg $danger "Error: This script requires Ubuntu 20.04 or 22.04\n\n"
	    exit
	fi

	sudo apt -y install curl gnupg gnupg2

	sudo mkdir -p /etc/apt/keyrings/
	sudo curl https://www.postgresql.org/media/keys/ACCC4CF8.asc --output /etc/apt/keyrings/postgresql.asc

	sudo rm -f /etc/apt/sources.list.d/postgresql.list
	echo "deb [signed-by=/etc/apt/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee -a /etc/apt/sources.list.d/postgresql.list

	sudo apt-get -y update
	sudo apt-get -y install \
	    apache2-utils \
	    apt-transport-https \
	    ca-certificates \
	    certbot \
	    dirmngr \
	    git \
	    nano \
	    network-manager \
	    net-tools \
	    openjdk-11-jdk \
	    openssh-server \
	    openssl \
	    software-properties-common \
	    pwgen \
	    qrencode \
	    ufw \
	    unzip \
	    uuid-runtime \
	    vim \
	    wget \
	    zip
else 
    msg $warn "\n-------- Dependency script only meant for ubuntu --------\n"
fi