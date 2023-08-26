#!/bin/bash

SUDO=""
if [[ "$1" == "priv" ]]; then
    SUDO="sudo -E"
fi

cd ${CERT_PATH}

${SUDO} sed -i \
    -e "s/=US/=\${COUNTRY}/g" cert-metadata.sh

${SUDO} mkdir -p files
echo "unique_subject=no" | ${SUDO} tee files/crl_index.txt.attr
while true; do
    printf $info "\n\n------------ Generating Certificates --------------"
    printf $info "\n\nIf prompted to replace certificate, enter Y\n"
    pause

    printf $success "\n\nRoot: ${TAK_ALIAS}-Root-CA-01\n"
    ${SUDO} ./makeRootCa.sh --ca-name $root ${TAK_ALIAS}-Root-CA-01
    if [ $? -eq 0 ]; then
        printf $success "\n\nCA: ${TAK_CA}\n"
        ${SUDO} ./makeCert.sh ca ${TAK_CA}
        if [ $? -eq 0 ]; then
            printf $success "\n\nServer: ${TAK_ALIAS}\n"
            ${SUDO} ./makeCert.sh server ${TAK_ALIAS}
            if [ $? -eq 0 ]; then
                printf $success "\n\nAdmin: ${TAKADMIN}\n"
                ${SUDO} ./makeCert.sh client ${TAKADMIN}
                if [ $? -eq 0 ]; then
                    break
                fi
            fi
        fi
    fi
    sleep 10
done

source ${TAK_SCRIPT_PATH}/v1/letsencrypt-import.inc.sh