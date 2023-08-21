# Tak Tools

- [Standalone](#standalone)
- [Docker](#docker)

## Inspiration

- https://github.com/Cloud-RF/tak-server
- https://github.com/atakhq/tak-server-install-scripts

# Prep this repository

```
sudo apt -y update; \
sudo apt -y install git; \
sudo git clone https://github.com/cgmckeever/tak-tools.git /opt/tak-tools
```

# VPN [optional]

## Wireguard

[Simple Wireguard Setup](https://github.com/cgmckeever/wireguard-tools)

You will be able to access the TAK Server via `https://{WIREGUARD-TAK-SERVER-IP}:8446` (or create a DNS entry for a domain name)

## Zero Tier

- Create an account at [zerotier.com](https://www.zerotier.com)
- Create a new ZeroTier Network via the UI

- Install ZeroTier
```
curl -s https://install.zerotier.com | sudo bash
```

- Add TAK Server as ZeroTier Node
```
sudo zerotier-cli join {ZEROTIER-NETWORK-ID}
```

- In the ZeroTier UI, allow the TAK Server Access
- Repeat for each peer/node

You will be able to access the TAK Server via `https://{ZEROTIER-TAK-SERVER-IP}:8446`. You can manually add a memorable IP in the UI,  or create a DNS entry for a domain name.


# LetsEncrypt [optional]

```
/opt/tak-tools/scripts/letsencrypt.sh
```

- Will prompt you for a FQDN
- Port 80 *must* be exposed to the internet `sudo ufw allow 80` [remember to remove after]
- The `setup.sh` script will find the `letsencrypt.txt` file and enable

# Standalone

## Validated

- Ubuntu 22.04
    - [TAK 4.8](https://tak.gov/products/tak-server?product_version=tak-server-4-8-0) [ ARM64 ]
    - [TAK 4.9](https://tak.gov/products/tak-server?product_version=tak-server-4-9-0) [ AMD64 | ARM64 ]
    - [TAK 4.10](https://tak.gov/products/tak-server?product_version=tak-server-4-10-0) [ AMD64 | ARM64 ]

## Prereq

### System

```
/opt/tak-tools/scripts/tak/standalone/prereq.sh

```

- Install prereq libraries
- Enables UFW [Firewall]

### TAK Package

- Download the package from https://tak.gov/products/tak-server
- Transfer it to your server in the `/tmp` directory

## Setup

- Copy and change the config settings
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

- Will look for the install package as `/tmp/takserver*.zip`
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

run as `tak` service user `su - tak`

### Create

```
tools/create-client-cert.sh
```

- Will create a client `p12` and `pem` files
- Requires a reboot to be picked-up
- You will need to manually create a user in the `administrative` user manager with the same name to sync groups

### Revoke

```
tools/revoke-client-cert.sh
```

- Revoke client `p12` and `pem` files
- Requires a reboot to be picked-up

## Create Client Data Package

```
tools/client-data-package.sh
```

- Will generate the Client Data Package

# Docker

## Validated

- Ubuntu 20.04
    - [TAK 4.8](https://tak.gov/products/tak-server?product_version=tak-server-4-8-0) [ AMD64 ]
- Ubuntu 22.04
    - [TAK 4.8](https://tak.gov/products/tak-server?product_version=tak-server-4-8-0) [ ARM64 ]
    - [TAK 4.9](https://tak.gov/products/tak-server?product_version=tak-server-4-9-0) [ AMD64 | ARM64 ]
    - [TAK 4.10](https://tak.gov/products/tak-server?product_version=tak-server-4-10-0) [ AMD64 ]

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
- Transfer it to your server in the `/home/tak/release/` directory


## Setup

- Log in as the TAK user
```
su - tak
```

- Copy and change the config settings
```
sudo cp /opt/tak-tools/scripts/tak/docker/config.inc.example.sh \
    /opt/tak-tools/scripts/tak/docker/config.inc.sh; \
cat /opt/tak-tools/scripts/tak/docker/config.inc.sh

ln -s /opt/tak-tools/scripts/tak/docker/ ~/tools
```

- Kick off setup
```
tools/tear-down.sh
tools/setup.sh
```

Wrapper Script: `tools/start.sh`

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
tools/create-client-cert.sh
```

- Will create a client `p12` and `pem` files
- Requires a reboot to be picked-up
- You will need to manually create a user in the `administrative` user manager with the same name to sync groups

### Revoke

```
tools/revoke-client-cert.sh
```

- Revoke client `p12` and `pem` files
- Requires a reboot to be picked-up

## Create Client Data Package

```
tools/client-data-package.sh
```

- Will generate the Client Data Package

## Upgrade

Not all persisted data has been tested across upgrade. Original working directory should
remain peristed in the `release/` directory for reference.

```
tool/upgrade.sh
```

- Will ask for name of the new release package
- Backup configs/certs
- Copy new TAK files over
- Restart TAK

## Tear down

```
tools/tear-down.sh
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

## NetworkManager

- Update renderer in `/etc/netplan/50-cloud-init.yaml` from `networkd` to `NetworkManager`

```
network:
    version: 2
    wifis:
        renderer: NetworkManager
```

```
sudo netplan apply
```

- Find SSIDs

```
sudo nmcli dev wifi
```

- Change wifi

```
sudo nmcli device wifi --ask connect {SSID-TO-CONNECT}
```

