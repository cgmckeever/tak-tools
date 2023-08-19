#!/bin/bash

cd ${CERT_PATH}
mkdir -p files
sudo echo "unique_subject=no" > files/crl_index.txt.attr
while true; do
    printf $info "\n\n------------ Generating Certificates --------------"
    printf $info "\n\nIf prompted to replace certificate, enter Y\n"
    pause

    printf $success "\n\nRoot: ${TAK_ALIAS}-Root-CA-01\n"
    ./makeRootCa.sh --ca-name $root ${TAK_ALIAS}-Root-CA-01
    if [ $? -eq 0 ]; then
        printf $success "\n\nCA: ${TAK_CA}\n"
        ./makeCert.sh ca ${TAK_CA}
        if [ $? -eq 0 ]; then
            printf $success "\n\nServer: ${TAK_ALIAS}\n"
            ./makeCert.sh server ${TAK_ALIAS}
            if [ $? -eq 0 ]; then
                printf $success "\n\nAdmin: ${TAKADMIN}\n"
                ./makeCert.sh client ${TAKADMIN}
                if [ $? -eq 0 ]; then
                    break
                fi
            fi
        fi
    fi
    sleep 10
done