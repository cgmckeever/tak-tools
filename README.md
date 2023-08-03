# Tak Tools

# Docker

## Prereq

### System

```
sudo apt -y update
sudo apt -y install \
    git

git clone https://github.com/cgmckeever/tak-tools.git /opt/tak-tools

/opt/tak-tools/docker/prereq.sh

```

- Install prereq libraries
- Install docker and docker-compose
- Enables UFW [Firewall]
- Will create a `tak` service user
    - *Remember* the displayed password; or `passwd tak` to change it

### TAK Docker

- Download the docker package from https://tak.gov/products/tak-server
- transfer it to your server in the `/tmp` directory

## LetsEncrypt [optional]

```
su - tak
/opt/tak-tools/scripts/letsencrypt.sh
```

- Will prompt you for a FQDN
- Port 80 *must* be exposed to the internet `sudo ufw allow 80` [remember to remove after]
- The `setup.sh` script will find the `letsencrypt.txt` file and enable

## Setup

```
su - tak
/opt/tak-tools/scripts/docker/setup.sh

```

- Will look for the docker install package as `/tmp/takserver*.zip`


## Manually Create Client Certs

```
/opt/tak-tools/scripts/docker/create-client-cert.sh
```

- Will create aa cclient `p12` and `pem` files
- Requires a reboot to be picked-up
- You will need to manually create a user in the `administrative` user manager with the same name to sync groups

## Create Client Data Package

```
/opt/tak-tools/scripts/docker/client-data-package.sh
```

- Will generate the Client Data Package

# Firewall

```
NIC=wg0 ## or eth0 etc
TAK_IP=$(ip addr show ${NIC} | grep -m 1 "inet " | awk '{print $2}' | cut -d "/" -f1)
sudo ufw default deny incoming; \
sudo ufw default allow outgoing; \
sudo ufw allow 51820/udp; \
sudo ufw allow OpenSSH; \
sudo ufw allow proto tcp from ${TAK_IP}/24 to any port 8089; \
sudo ufw allow proto tcp from ${TAK_IP}/24 to any port 8443; \
sudo ufw allow proto tcp from ${TAK_IP}/24 to any port 8446; \
sudo ufw enable; \
sudo ufw status
```