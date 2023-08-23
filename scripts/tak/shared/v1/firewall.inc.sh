#!/bin/bash

printf $warning "\n\nThis is a simple/universal firewall configuration script for TAK.\n"
printf $warning "You should verify that its not making unanticipated changes.\n"

source ${TAK_SCRIPT_PATH}/v1/firewall-update.inc.sh
printf $warning "\n\n------------ Current Firewall Rules ------------\n"
sudo ufw status numbered