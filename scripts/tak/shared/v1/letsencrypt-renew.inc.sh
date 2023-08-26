#!/bin/bash

printf $warning "\n\nRequesting a certificate renewal...\n\n"
IFS=':' read -ra LE_INFO <<< $(cat ~/letsencrypt.txt)
source ${TOOLS_PATH}/scripts/shared/letsencrypt.inc.sh ${LE_INFO[0]} ${LE_INFO[1]}