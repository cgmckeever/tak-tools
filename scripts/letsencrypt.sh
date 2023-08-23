#!/bin/bash

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
TOOLS_PATH=$(dirname $(dirname $SCRIPT_PATH))
echo $TOOLS_PATH
source ${TOOLS_PATH}/scripts/shared/functions.inc.sh

# install certbot
#
sudo apt install -y certbot

echo; echo
printf $warning "Requesting a new certificate...\n\n"

read -p  "What is your domain name? [ex: atakhq.com or tak.foo.com] " FQDN

echo
read -p "What is your email? [Needed for LetsEncrypt Alerts] : " EMAIL

echo
read -p "Validate using [w]eb (must have port 80 exposed) or [d]ns: " VALIDATOR
VALIDATOR=${VALIDATOR:-w}

echo
CERT="failed"
case $(VALIDATOR) in
  "d")
    if sudo certbot certonly --manual --preferred-challenges dns -d ${FQDN} -m ${EMAIL}; then
      CERT="issued"
    fi
  *)
    if sudo certbot certonly --standalone -d ${FQDN} -m ${EMAIL} --agree-tos --non-interactive; then
      CERT="issued"
    fi
    ;;
esac

if [[ "${CERT}" == "issued" ]]; then
  printf $success "Certificate obtained successfully!\n\n"
  echo $FQDN > ~/letsencrypt.txt
else
  printf $warning "Error obtaining certificate: $(sudo certbot certificates)"
fi

