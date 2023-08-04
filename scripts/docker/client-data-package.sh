#!/bin/bash

SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
source ${SCRIPT_PATH}/shared.inc.sh

# =======================

printf $warning "\n\n------------ Creating TAK Client Data Package ------------ \n\n"

TAK_ALIAS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_ALIAS" | tr -d '\r')
URL=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$URL" | tr -d '\r')
CAPASS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
PASS=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')
TAK_COT_PORT=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_COT_PORT" | tr -d '\r')
TAK_CA=$($DOCKER_COMPOSE -f ${WORK_DIR}/docker-compose.yml exec tak-server bash -c "echo \$TAK_CA" | tr -d '\r')

read -p "Create data package for which user: " USERNAME
rm -rf ${FILE_PATH}/clients/${USERNAME}
mkdir -p ${FILE_PATH}/clients/${USERNAME}

tee ${FILE_PATH}/clients/${USERNAME}/manifest.xml >/dev/null << EOF
<MissionPackageManifest version="2">
    <Configuration>
        <Parameter name="uid" value="bcfaa4a5-2224-4095-bbe3-fdaa22a82741"/>
        <Parameter name="name" value="${USERNAME}-${TAK_ALIAS}-DP"/>
        <Parameter name="onReceiveDelete" value="true"/>
    </Configuration>
    <Contents>
        <Content ignore="false" zipEntry="certs\server.pref"/>
        <Content ignore="false" zipEntry="certs\\truststore-${TAK_CA}.p12"/>
        <Content ignore="false" zipEntry="certs\\${USERNAME}.p12"/>
    </Contents>
</MissionPackageManifest>
EOF


tee ${FILE_PATH}/clients/${USERNAME}/server.pref >/dev/null << EOF
<?xml version='1.0' encoding='ASCII' standalone='yes'?>
<preferences>
    <preference version="1" name="cot_streams">
        <entry key="count" class="class java.lang.Integer">1</entry>
        <entry key="description0" class="class java.lang.String">${USERNAME}-${TAK_ALIAS}</entry>
        <entry key="enabled0" class="class java.lang.Boolean">true</entry>
        <entry key="connectString0" class="class java.lang.String">${URL}:${TAK_COT_PORT}:ssl</entry>
    </preference>
    <preference version="1" name="com.atakmap.app_preferences">
        <entry key="displayServerConnectionWidget" class="class java.lang.Boolean">true</entry>
        <entry key="caLocation" class="class java.lang.String">cert/truststore-${TAK_CA}.p12</entry>
        <entry key="caPassword" class="class java.lang.String">${CAPASS}</entry>
        <entry key="clientPassword" class="class java.lang.String">${PASS}</entry>
        <entry key="certificateLocation" class="class java.lang.String">cert/${USERNAME}.p12</entry>
    </preference>
</preferences>
EOF

cd ${FILE_PATH}/clients/${USERNAME}/
zip -j ${USERNAME}-${TAK_ALIAS}.zip \
    ${FILE_PATH}/${USERNAME}.p12 \
    ${FILE_PATH}/${USERNAME}.pem \
    ${FILE_PATH}/truststore-${TAK_CA}.p12 \
    manifest.xml \
    server.pref

printf $info "\n\nUser Data Package Created: ${FILE_PATH}/clients/${USERNAME}/${USERNAME}-${TAK_ALIAS}.zip\n\n"
