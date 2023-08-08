## Definable variables
#  Copy this file to `config.inc.sh`
#
CAPASS="atakatak"               # CA Password [not fully tested if a change works]
CERTPASS="atakatak"             # User Cert Password [not fully tested if a change works]
DOCKER_SUBNET="172.20.0.0/24"   # Docker subnet as defined in docker-compose.yml
TAK_COT_PORT=8089               # TAK API Port [not fully tested if a change works]
TAKUSER=tak                     # TAK Service User - Installs TAK; needs sudo and docker priv
TAKADMIN=tak-admin              # TAK Web Admin