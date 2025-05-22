# Tak Tools

## TODO

- [ ] Better non `root` handling
- [-] Add Firewall and VPN support
- [ ] NGINX doc server
- [-] RasPi installer

### Aux Scripts

- TBD

## Prep this repository

```
sudo apt -y update; \
sudo apt -y install curl git; \
sudo git clone https://github.com/cgmckeever/tak-tools.git /opt/tak-tools; \
cd /opt/tak-tools; \
git checkout v2
```

### Prereq

```
scripts/prereq.sh 
```

When prompted, choose your installation type `ubuntu` or `docker`

### Environment Requirements 

For local dev on personal device, you can manage your own requirements

- `pwgen`
- `uuidgen`
- `qrencode`
- probably some more ...

## TAK Pack Bundle

- Download TAK release from [tak.gov](tak.gov)
- Move the `zip` or `deb` to `tak-pack/` 

## Install

```
scripts/setup.sh
```

### Post-Install

If the file `scripts/post-install.sh` exists, it will run after a successful install allowing custom post-installation steps. See `scripts/post-install-example.sh`

- Add users
- Move files

### Firewall

```
scripts/setup-firewall.sh
```

## Utilities

### TAK Utilities

#### Backup 

Creates a snapshot of TAK folder (not the DB)

```
scripts/backup.sh {TAK_ALIAS}
```

#### Certificate Bundler/Backup

Create a zip-bundle of the `certs/files` as backup

```
scripts/cert-bundler.sh {TAK_ALIAS}
```

#### System Manager

Perform a `start`, `stop`, `status`, or `restart`

```
scripts/system.sh {TAK_ALIAS} {start|stop|status|restart}
```

#### Tear-Down

```
scripts/{docker|ubuntu}/tear-down.sh {TAK_ALIAS}
```

#### Upgrade (Docker only)

- backs up config and `tak` directory
- unpacks new docker zip
- syncs previous certificates

```
scripts/docker/upgrade.sh {TAK_ALIAS}
```

### User Management

#### Create 

```
scripts/user-gen.sh {TAK_ALIAS} {USERNAME} "{PASSWORD}"
```

#### Revoke Cert

```
scripts/user-cert-revoke.sh {TAK_ALIAS} {USERNAME}
```

\*Requires a reboot to take effect

### LetsEncrypt

#### Request Cert

```
scripts/letsencrypt-request.sh {TAK_ALIAS}
```

#### Import Cert

```
scripts/letsencrypt-import.sh {TAK_ALIAS}
```

\*Requires `CoreConfig.xml` to be properly configured to use LetsEncrypt [handled during install]

\*Requires a reboot to take effect


## Validated

### Docker

- 4.10 	[MBP / Ubuntu 22.04]
- 5.2 	[MBP / Ubuntu 22.04 / RasPi4]

### Ubuntu

- Ubuntu 22.04
	- 5.2 [x86_64 / RasPi4]

## Previous Versions

- v1 [release](https://github.com/cgmckeever/tak-tools/releases/tag/v1) can be [browsed here](https://github.com/cgmckeever/tak-tools/tree/v1)
