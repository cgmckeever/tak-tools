#!/bin/bash

printf $warning "\n\n------------ Creating TAK Auto-Enroll Data Package ------------ \n\n"

read -p "Server Connection String [${TAK_URL}]: " CONNECTION_STRING
CONNECTION_STRING=${CONNECTION_STRING:-${TAK_URL}}

mkdir -p ${FILE_PATH}/clients
UUID=$(uuidgen -r)

sudo tee ${FILE_PATH}/clients/manifest.xml >/dev/null << EOF
<MissionPackageManifest version="2">
    <Configuration>
        <Parameter name="uid" value="${UUID}"/>
        <Parameter name="name" value="${TAK_ALIAS}-${CONNECTION_STRING}-AutoEnroll-DP"/>
        <Parameter name="onReceiveDelete" value="true"/>
    </Configuration>
    <Contents>
        <Content ignore="false" zipEntry="server.pref"/>
        <Content ignore="false" zipEntry="truststore-${TAK_CA}.p12"/>
    </Contents>
</MissionPackageManifest>
EOF


sudo tee ${FILE_PATH}/clients/server.pref >/dev/null << EOF
<?xml version='1.0' encoding='ASCII' standalone='yes'?>
<preferences>
    <preference version="1" name="cot_streams">
        <entry key="count" class="class java.lang.Integer">1</entry>
        <entry key="description0" class="class java.lang.String">${TAK_ALIAS}</entry>
        <entry key="enabled0" class="class java.lang.Boolean">true</entry>
        <entry key="connectString0" class="class java.lang.String">${CONNECTION_STRING}:${TAK_COT_PORT}:ssl</entry>
        <entry key="enrollForCertificateWithTrust0" class="class java.lang.Boolean">true</entry>
        <entry key="useAuth0" class="class java.lang.Boolean">true</entry>
        <entry key="cacheCreds0" class="class java.lang.String">Cache credentials</entry>
        <entry key="caLocation0" class="class java.lang.String">cert/truststore-${TAK_CA}.p12</entry>
        <entry key="caPassword0" class="class java.lang.String">${CAPASS}</entry>
    </preference>
    <preference version="1" name="com.atakmap.app_preferences">
        <entry key="displayServerConnectionWidget" class="class java.lang.Boolean">true</entry>
        <entry key="locationTeam" class="class java.lang.String">Blue</entry>
    </preference>
</preferences>
EOF

echo; echo
cd ${FILE_PATH}/clients/
ZIP=${TAK_ALIAS}-${CONNECTION_STRING}
sudo zip -j ${ZIP}.zip \
    ${FILE_PATH}/truststore-${TAK_CA}.p12 \
    manifest.xml \
    server.pref

printf $info "\n\nAuto-Enroll Data Package Created: ${FILE_PATH}/clients/${ZIP}.zip\n\n"
