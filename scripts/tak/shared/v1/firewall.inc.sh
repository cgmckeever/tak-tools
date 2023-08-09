#!/bin/bash

printf $warning "\n\n------------ Updating UFW Firewall Rules ------------\n\n"

printf $info "Allow 22 [SSH]\n"
sudo ufw allow OpenSSH;
printf $info "\nAllow 8089 [API]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8089
printf $info "\nAllow 8443 [certificate auth]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8443
printf $info "\nAllow 8446 [user/pass auth]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 8446
printf $info "\nAllow 9000 [federation]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 9000
printf $info "\nAllow 9001 [federation]\n"
sudo ufw allow proto tcp from ${IP}/24 to any port 9001