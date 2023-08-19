#!/bin/bash

# We are done now
#
########################## OUTPUT ##########################
#
#
printf $info "Certificates and *CERT DATA PACKAGES* are in tak/certs/files \n"
printf $warning "Import the ${CERT_PATH}/files/$TAKADMIN.p12 certificate to your browser as per the README\n\n"

printf $success "Login at https://$URL:8443 with your admin account certificate.\n\n"
printf $success "Login at https://$URL:8446 with your admin account user/pass.\n"
printf $success "No need to run the /setup step as this has been done.\n\n"

INFO=${1}/info.txt
echo "---------PASSWORDS----------------" | sudo tee ${INFO} >/dev/null
echo | sudo tee -a ${INFO} >/dev/null
echo "Tak Admin user      : $TAKADMIN" | sudo tee -a ${INFO} >/dev/null
echo "Tak Admin password  : $TAKADMIN_PASS" | sudo tee -a ${INFO} >/dev/null
echo "PostgreSQL password : $PG_PASS" | sudo tee -a ${INFO} >/dev/null
echo | sudo tee -a ${INFO} >/dev/null
echo "---------PASSWORDS----------------" | sudo tee -a ${INFO} >/dev/null
printf $danger "$(sudo cat ${INFO})"

printf $warning "\nMAKE A NOTE OF YOUR PASSWORDS. THEY WON'T BE SHOWN AGAIN.\n\n
"
printf $warning "You have a database listening on TCP 5432 which requires a login. You should still block this port with a firewall\n\n"