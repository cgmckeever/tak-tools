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

INFO=${WORK_PATH}/info.txt
sudo echo "---------PASSWORDS----------------" > ${INFO}
sudo echo >> ${INFO}
sudo echo "Tak Admin user      : $TAKADMIN" >> ${INFO}
sudo echo "Tak Admin password  : $TAKADMIN_PASS" >> ${INFO}
sudo echo "PostgreSQL password : $PG_PASS" >> ${INFO}
sudo echo >> ${INFO}
sudo echo "---------PASSWORDS----------------" >> ${INFO}
printf $danger "$(sudo cat ${INFO})"

printf $warning "\nMAKE A NOTE OF YOUR PASSWORDS. THEY WON'T BE SHOWN AGAIN.\n\n
"
printf $warning "You have a database listening on TCP 5432 which requires a login. You should still block this port with a firewall\n\n"