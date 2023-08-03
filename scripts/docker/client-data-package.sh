#!/bin/bash

color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m      # cyan
color success 92m   # green
color warning 93m   # yellow
color danger 91m    # red

TAK_ALIAS=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$TAK_ALIAS" | tr -d '\r')
URL=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$URL" | tr -d '\r')
CAPASS=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
PASS=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$PASS" | tr -d '\r')
TAK_COT_PORT=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$TAK_COT_PORT" | tr -d '\r')
TRUSTSTORE=$(docker compose -f tak-server/release/compose.yml exec tak-server bash -c "echo \$TRUSTSTORE" | tr -d '\r')

read -p "Create data package for which user: " USERNAME

CERT_PATH=~/tak-server/release/tak/certs/files
rm -rf $CERT_PATH/clients/$USERNAME
mkdir -p $CERT_PATH/clients/$USERNAME


tee ${CERT_PATH}/clients/$USERNAME/manifest.xml >/dev/null << EOF
<MissionPackageManifest version="2">
<Configuration>
<Parameter name="uid" value="bcfaa4a5-2224-4095-bbe3-fdaa22a82741"/>
<Parameter name="name" value="${USERNAME}-${TAK_ALIAS}-DP"/>
<Parameter name="onReceiveDelete" value="true"/>
</Configuration>
<Contents>
<Content ignore="false" zipEntry="certs\server.pref"/>
<Content ignore="false" zipEntry="certs\\truststore-${TRUSTSTORE}.p12"/>
<Content ignore="false" zipEntry="certs\\${USERNAME}.p12"/>
</Contents>
</MissionPackageManifest>
EOF


tee ${CERT_PATH}/clients/$USERNAME/server.pref >/dev/null << EOF
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
    <entry key="caLocation" class="class java.lang.String">cert/truststore-$TRUSTSTORE.p12</entry>
    <entry key="caPassword" class="class java.lang.String">$CAPASS</entry>
    <entry key="clientPassword" class="class java.lang.String">$PASS</entry>
    <entry key="certificateLocation" class="class java.lang.String">cert/${USERNAME}.p12</entry>
  </preference>
</preferences>
EOF

cd ${CERT_PATH}/clients/${USERNAME}/
zip -j ${USERNAME}-${TAK_ALIAS}.zip \
    ${CERT_PATH}/${USERNAME}.p12 \
    ${CERT_PATH}/${USERNAME}.pem \
    ${CERT_PATH}/truststore-${TRUSTSTORE}.p12 \
    manifest.xml \
    server.pref

printf $info "User Data Package Created: ${CERT_PATH}/clients/${USERNAME}/${USERNAME}-${TAK_ALIAS}.zip\n\n"
