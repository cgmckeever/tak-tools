#!/bin/bash

WORK_DIR=~/tak-server

# install certbot
#
sudo apt install -y certbot openjdk-16-jre-headless

read -p  "What is your domain name? [ex: atakhq.com or tak-public.atakhq.com] " FQDN
NAME=${FQDN//\./-}

# request inital cert
#
echo ""
echo "Requesting a new certificate..."
echo ""
read -p "What is your email? [Needed for Letsencrypt Alerts] : " EMAIL

if certbot certonly --standalone -d $FQDN -m $EMAIL --agree-tos --non-interactive; then
  echo "Certificate obtained successfully!"
  echo $FQDN > letsencrypt.txt
else
  echo "Error obtaining certificate: $(sudo certbot certificates)"
  exit 1
fi