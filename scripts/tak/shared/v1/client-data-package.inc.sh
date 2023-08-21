#!/bin/bash

printf $warning "\n\n------------ Creating TAK Client Data Package ------------ \n\n"

USERNAME=$1
if [ -z "${USERNAME}" ]; then
    read -p "Create data package for which user: " USERNAME
fi
rm -rf ${FILE_PATH}/clients/${USERNAME}
mkdir -p ${FILE_PATH}/clients/${USERNAME}

echo; echo
read -p "Server Connection String [${TAK_URL}]: " CONNECTION_STRING
CONNECTION_STRING=${CONNECTION_STRING:-${TAK_URL}}

UUID=$(uuidgen -r)

tee ${FILE_PATH}/clients/${USERNAME}/manifest.xml >/dev/null << EOF
<MissionPackageManifest version="2">
    <Configuration>
        <Parameter name="uid" value="${UUID}"/>
        <Parameter name="name" value="${USERNAME}-${TAK_ALIAS}-DP"/>
        <Parameter name="onReceiveDelete" value="true"/>
    </Configuration>
    <Contents>
        <Content ignore="false" zipEntry="server.pref"/>
        <Content ignore="false" zipEntry="truststore-${TAK_CA}.p12"/>
        <Content ignore="false" zipEntry="${USERNAME}.p12"/>
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
        <entry key="connectString0" class="class java.lang.String">${CONNECTION_STRING}:${TAK_COT_PORT}:ssl</entry>
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

echo; echo
cd ${FILE_PATH}/clients/${USERNAME}/
ZIP=${USERNAME}-${TAK_ALIAS}-${CONNECTION_STRING}
zip -j ${ZIP}.zip \
    ${FILE_PATH}/${USERNAME}.p12 \
    ${FILE_PATH}/${USERNAME}.pem \
    ${FILE_PATH}/truststore-${TAK_CA}.p12 \
    manifest.xml \
    server.pref

printf $info "\n\nUser Data Package Created: ${FILE_PATH}/clients/${USERNAME}/${ZIP}.zip\n\n"
