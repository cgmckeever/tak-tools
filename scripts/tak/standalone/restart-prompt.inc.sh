#!/bin/bash

printf $warning "\n\nTAK needs to restart to enable changes.\n\n"
read -p "Restart TAK [y/n]? " RESTART

if [[ $RESTART =~ ^[Yy]$ ]];then
    systemctl restart takserver
fi