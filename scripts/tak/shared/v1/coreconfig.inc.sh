#!/bin/bash

printf $warning "\n\n------------ Updating CoreConfig.xml ------------\n\n"

sudo touch ${TAK_PATH}/CoreConfig.xml
sudo cp ${TAK_PATH}/CoreConfig.xml ${TAK_PATH}/CoreConfig.xml.install
sudo cp ${TEMPLATE_PATH}/tak/CoreConfig-${VERSION}.xml.tmpl ${TAK_PATH}/CoreConfig.xml

ACTIVE_SSL=SELF_SSL
if [[ -f ~/letsencrypt.txt ]]; then
    printf $info "Enabling LetsEncrypt on Port:8446\n\n"
    ACTIVE_SSL=LE_SSL
    FQDN=$(cat ~/letsencrypt.txt)
    URL=$FQDN
fi

DATABASE_HOST=$1
SIGNING_KEY=${TAK_CA}-signing
PG_PASS=${PAD2}$(pwgen -cvy1 -r ${PASS_OMIT} 25)${PAD1}
sudo sed -i \
    -e "/<!--${ACTIVE_SSL}/d" \
    -e "/${ACTIVE_SSL}-->/d" \
    -e "s/__CAPASS/${CAPASS}/g" \
    -e "s/__PASS/${CERTPASS}/g" \
    -e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
    -e "s/__ORGANIZATION/${ORGANIZATION}/g" \
    -e "s/__TAK_CA/${TAK_CA}/g" \
    -e "s/__SIGNING_KEY/${SIGNING_KEY}/g" \
    -e "s/__CRL/${TAK_CA}/g" \
    -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
    -e "s/__HOSTIP/${IP}/g" \
    -e "s/__TAK_COT_PORT/${TAK_COT_PORT}/" \
    -e "s/__TAK_CLIENT_VALID/${TAK_CLIENT_VALID}/" \
    -e "s/__DATABASE_HOST/${DATABASE_HOST}/" \
    -e "s/__PG_PASS/${PG_PASS}/" ${TAK_PATH}/CoreConfig.xml

printf $info "Setting TAK Server Alias: ${TAK_ALIAS}\n"
printf $info "Setting HOST IP: ${IP}\n"
printf $info "Setting API Port: ${TAK_COT_PORT}\n\n"

printf $info "Setting CA: ${TAK_CA}\n"
printf $info "Setting CA Cert Password\n"
printf $info "Setting CA Organization Info O: ${ORGANIZATION} OU: ${ORGANIZATIONAL_UNIT}\n"
printf $info "Setting CA Revocation List: ${TAK_CA}.crl\n\n"

printf $info "Setting PostGres URL: ${DATABASE_HOST}\n"
printf $info "Setting PostGres Password: ${PG_PASS}\n\n"

pause