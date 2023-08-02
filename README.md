# tak-tools

# Prereq

```
sudo apt -y update
sudo apt -y install \
    git

git clone https://github.com/cgmckeever/tak-tools.git /opt/tak-tools

/opt/tak-tools/docker/prereq.sh

```

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