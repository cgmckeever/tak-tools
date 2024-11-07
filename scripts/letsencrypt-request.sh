#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

if [ "${LE_VALIDATOR}" = "web" ]; then
    msg $warn "\nRequesting LetsEncrypt: HTTP Validator"
    sudo certbot certonly --standalone -d ${TAK_URI} -m ${LE_EMAIL}  --agree-tos --non-interactive
else
    msg $warn "\nRequesting LetsEncrypt: DNS Validator"
    sudo certbot certonly --manual --preferred-challenges dns -d ${TAK_URI} -m ${LE_EMAIL}
fi

pause