# Tak Tools

## Inspiration

- https://github.com/Cloud-RF/tak-server
- https://github.com/atakhq/tak-server-install-scripts

# Prep this repository

```
sudo apt -y update; \
sudo apt -y install git; \
sudo git clone https://github.com/cgmckeever/tak-tools.git /opt/tak-tools
```

# LetsEncrypt [optional]

```
su - tak
/opt/tak-tools/scripts/letsencrypt.sh
```

- Will prompt you for a FQDN
- Port 80 *must* be exposed to the internet `sudo ufw allow 80` [remember to remove after]
- The `setup.sh` script will find the `letsencrypt.txt` file and enable

# Standalone

## Validated

## Prereq

### System

```
/opt/tak-tools/scripts/tak/standalone/prereq.sh

```

- Install prereq libraries
- Enables UFW [Firewall]

### TAK Package

- Download the package from https://tak.gov/products/tak-server
- Transfer it to your server in the `~/release/` directory

## Setup

```

- Copy and change th config settings
```
sudo cp /opt/tak-tools/scripts/tak/standalone/config.inc.example.sh \
    /opt/tak-tools/scripts/tak/standalone/config.inc.sh; \
cat /opt/tak-tools/scripts/tak/standalone/config.inc.sh
```

- Kick off setup
```
/opt/tak-tools/scripts/tak/standalone/setup.sh
```

Wrapper Script: `/opt/tak-tools/scripts/tak/standalone/start.sh`

- Will look for the install package as `~/release/takserver*.zip`
- Follow the prompts...its not perfect

## Start/Stop

- Start
```
sudo systemctl start takserver
```

- Stop
```
sudo systemctl stop takserver
```

- Autostart
```
sudo systemctl enable takserver
```

## Manage Client Certs

### Create

```
/opt/tak-tools/scripts/tak/standalone/create-client-cert.sh
```

- Will create a client `p12` and `pem` files
- Requires a reboot to be picked-up
- You will need to manually create a user in the `administrative` user manager with the same name to sync groups

### Revoke

```
/opt/tak-tools/scripts/tak/standalone/revoke-client-cert.sh
```

- Revoke client `p12` and `pem` files
- Requires a reboot to be picked-up

## Create Client Data Package

```
/opt/tak-tools/scripts/tak/standalone/client-data-package.sh
```

- Will generate the Client Data Package

# Docker

## Validated

- Ubuntu 20.04
    - [TAK 4.8](https://tak.gov/products/tak-server?product_version=tak-server-4-8-0) [ AMD64 ]
- Ubuntu 22.04
    - [TAK 4.8](https://tak.gov/products/tak-server?product_version=tak-server-4-8-0) [ ARM64 ]
    - [TAK 4.9](https://tak.gov/products/tak-server?product_version=tak-server-4-9-0) [ AMD64 | ARM64 ]

## Prereq

### System

```
/opt/tak-tools/scripts/tak/docker/prereq.sh

```

- Install prereq libraries
- Install docker and docker-compose
- Enables UFW [Firewall]
- Will create a `tak` service user
    - *Remember* the displayed password; or `passwd tak` to change it

### TAK Docker Package

- Download the docker package from https://tak.gov/products/tak-server
- Transfer it to your server in the `~/release/` directory


## Setup

- Log in as the TAK user
```
su - tak
```

- Copy and change th config settings
```
sudo cp /opt/tak-tools/scripts/tak/docker/config.inc.example.sh \
    /opt/tak-tools/scripts/tak/docker/config.inc.sh; \
cat /opt/tak-tools/scripts/tak/docker/config.inc.sh
```

- Kick off setup
```
/opt/tak-tools/scripts/tak/docker/tear-down.sh
/opt/tak-tools/scripts/tak/docker/setup.sh
```

Wrapper Script: `/opt/tak-tools/scripts/tak/docker/start.sh`

- Tear down and clean up Docker
- Will look for the docker install package as `~/release/takserver*.zip`
- Follow the prompts...its not perfect

## Start/Stop

- Start
```
sudo systemctl start tak-server-docker
```

- Stop
```
sudo systemctl stop tak-server-docker
```

- Autostart
```
sudo systemctl enable tak-server-docker
```

## Manually Create Client Certs

### Create

```
/opt/tak-tools/scripts/tak/docker/create-client-cert.sh
```

- Will create a client `p12` and `pem` files
- Requires a reboot to be picked-up
- You will need to manually create a user in the `administrative` user manager with the same name to sync groups

### Revoke

```
/opt/tak-tools/scripts/tak/docker/revoke-client-cert.sh
```

- Revoke client `p12` and `pem` files
- Requires a reboot to be picked-up

## Create Client Data Package

```
/opt/tak-tools/scripts/tak/docker/client-data-package.sh
```

- Will generate the Client Data Package

## Tear down

```
/opt/tak-tools/scripts/tak/docker/tear-down.sh
```

# Firewall

```
clear
ip link show

echo; echo
DEFAULT_NIC=$(route | grep default | awk '{print $8}'); \
read -p "Which Network Interface? Default [${DEFAULT_NIC}] " NIC; \
NIC=${NIC:-${DEFAULT_NIC}} ;\
echo; \
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

# Notes

## Docker

- Check Docker network
```
docker network inspect $(docker network ls -q)
```

- Resource Usage
```
docker stats --no-stream
```

- Shell in
```
docker-compose -f tak-server/docker-compose.yml exec tak-server bash
```

## Random

- Allow other users to pull `tak-tools`
```
git config --global --add safe.directory '/opt/tak-tools'
```

- Pull `tak-tools`
```
sudo git -C /opt/tak-tools pull
```

- Change Admin Password [docker]
```
echo; read -p "New Admin Password: " TAKADMIN_PASS; docker-compose -f tak-server/docker-compose.yml exec tak-server bash -c "java -jar \${TAK_PATH}/utils/UserManager.jar usermod -A -p \"${TAKADMIN_PASS}\" tak-admin"
```

