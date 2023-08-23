#!/bin/bash

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
TOOLS_PATH=$(dirname $SCRIPT_PATH)
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

# install certbot
#
sudo apt install -y certbot

printf $warning "\n\nRequesting a new certificate...\n\n"
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh


