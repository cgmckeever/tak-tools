#!/bin/bash

printf $warning "\n\n------------ Creating TAK Auto-Enroll Data Package ------------ \n\n"

read -p "Server Connection String [${URL}]: " CONNECTION_STRING
CONNECTION_STRING=${CONNECTION_STRING:-${URL}}

mkdir -p ${FILE_PATH}/clients
UUID=$(uuidgen -r)


tee ${FILE_PATH}/clients/manifest.xml >/dev/null << EOF
<MissionPackageManifest version="2">
    <Configuration>
        <Parameter name="uid" value="${UUID}"/>
        <Parameter name="name" value="${TAK_ALIAS}-${CONNECTION_STRING}-AutoEnroll-DP"/>
        <Parameter name="onReceiveDelete" value="true"/>
    </Configuration>
    <Contents>
        <Content ignore="false" zipEntry="certs\server.pref"/>
        <Content ignore="false" zipEntry="certs\truststore-${TAK_CA}.p12"/>
    </Contents>
</MissionPackageManifest>
EOF


tee ${FILE_PATH}/clients/server.pref >/dev/null << EOF
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
    </preference>
    <preference version="1" name="com.atakmap.app_preferences">
        <entry key="caLocation" class="class java.lang.String">cert/truststore-${TAK_CA}.p12</entry>
        <entry key="caPassword" class="class java.lang.String">${CAPASS}</entry>
        <entry key="displayServerConnectionWidget" class="class java.lang.Boolean">true</entry>
        <entry key="locationTeam" class="class java.lang.String">Blue</entry>
    </preference>
</preferences>
EOF

cd ${FILE_PATH}/clients/
zip -j ${TAK_ALIAS}-${CONNECTION_STRING}.zip \
    ${FILE_PATH}/truststore-${TAK_CA}.p12 \
    manifest.xml \
    server.pref

printf $info "\n\nAuto-Enroll Data Package Created: ${FILE_PATH}/clients/${TAK_ALIAS}-${CONNECTION_STRING}.zip\n\n"
