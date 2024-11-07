#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh 

msg $warning "\n\n------------ Updating UFW Firewall Rules ------------\n\n"

msg $warning "Answering [y]es to the next prompt will restrict access to a VPN network.\n"
prompt "Is the TAK Server behind a VPN [y/N]? " VPN
VPN=${VPN:-n}

TRAFFIC_SOURCE="0.0.0.0/0"
if [[ ${VPN} =~ ^[Yy]$ ]];then
    IFS='.' read A B C D <<< ${IP_ADDRESS}
    NET_RANGE=${A}.${B}.${C}.0/24

    echo; echo
    prompt "VPN Traffic Range [${NET_RANGE}]: " TRAFFIC_SOURCE
    TRAFFIC_SOURCE=${TRAFFIC_SOURCE:-${NET_RANGE}}
fi

msg $info "Allow 22 [SSH]"
sudo ufw allow OpenSSH;
msg $info "\nAllow ${TAK_COT_PORT} [API]"
sudo ufw allow proto tcp from ${TRAFFIC_SOURCE} to any port ${TAK_COT_PORT}
msg $info "\nAllow 8443 [certificate auth]"
sudo ufw allow proto tcp from ${TRAFFIC_SOURCE} to any port 8443
msg $info "\nAllow 8446 [user/pass auth]"
sudo ufw allow proto tcp from ${TRAFFIC_SOURCE} to any port 8446
msg $info "\nAllow 9000 [federation]"
sudo ufw allow proto tcp from ${TRAFFIC_SOURCE} to any port 9000
msg $info "\nAllow 9001 [federation]"
sudo ufw allow proto tcp from ${TRAFFIC_SOURCE} to any port 9001

if [[ "${INSTALLER}" == "docker" ]];then 
	msg $info "\nAllow Docker 5432 [postgres]"
	sudo ufw allow proto tcp from ${DOCKER_SUBNET} to any port 5432
	sudo ufw route allow from ${DOCKER_SUBNET} to ${DOCKER_SUBNET}

	printf $info "\nAllowing Allow Docker Outbound"
	# https://www.mkubaczyk.com/2017/09/05/force-docker-not-bypass-ufw-rules-ubuntu-16-04/
	DOCKER_HOST_IP=$(sudo docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')
	sudo sed -i -e 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
	sudo iptables -t nat -A POSTROUTING ! -o docker0 -s ${DOCKER_HOST_IP} -j MASQUERADE
	sudo sh -c "iptables-save > /etc/iptables/rules.v4"
	echo "{ \"iptables\" : "false" }" > /etc/docker/daemon.json

	sudo docker restart $(docker ps -q)
fi

msg $warning "\n\n------------ Current Firewall Rules ------------\n"
sudo ufw enable
sudo ufw status numbered