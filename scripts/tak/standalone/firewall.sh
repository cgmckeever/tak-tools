#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

printf $warning "\n\nThis is a simple/universal firewall configuration script for TAK.\n"
printf $warning "You should verify that its not unanticipaated making updaates.\n"

source ${TAK_SCRIPT_PATH}/v1/firewall.inc.sh
sudo ufw status numbered