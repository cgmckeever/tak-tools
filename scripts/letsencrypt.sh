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

# install certbot
#
sudo apt install -y certbot

echo; echo
printf $warning "Requesting a new certificate...\n\n"

read -p  "What is your domain name? [ex: atakhq.com or tak.foo.com] " FQDN
NAME=${FQDN//\./-}

echo
read -p "What is your email? [Needed for LetsEncrypt Alerts] : " EMAIL

echo
if sudo certbot certonly --standalone -d ${FQDN} -m ${EMAIL} --agree-tos --non-interactive; then
  printf $success "Certificate obtained successfully!\n\n"
  echo $FQDN > ~/letsencrypt.txt
else
  printf $warning "Error obtaining certificate: $(sudo certbot certificates)"
fi