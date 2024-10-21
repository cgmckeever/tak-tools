####
#
#           These Defaults work; 
#           unless noted, you can change them as needed
#
####


## TAK
#
export TAK_DB_ALIAS=__TAK_DB_ALIAS    	# hostname/ip/fqdn for DB connection
export TAK_ADMIN=tak-admin              # TAK Web Admin
export TAK_COT_PORT=8089               	# TAK API Port [not fully tested if a change works]


## LetsEncrypt (optional)
#
export LETSENCRYPT="false"                                  # enable LE port 8446 cert (required for ITAK)
export LE_EMAIL="someone@somewhere.com"                     # email to send LetsEncrypt validations
export LE_VALIDATOR="dns"                     				# validator type ("web" or "dns")


## Certificate info - Change these as needed
#
export CA_PASS=atakatak      											# CA Password
export CERT_PASS=atakatak												# User Cert Password
export ORGANIZATION=taktools											# CA organization name
export ORGANIZATIONAL_UNIT=tak 											# CA organization unit
export CITY=XX 															# CA city
export STATE=XX 														# CA state
export COUNTRY=US 														# CA country (2 letter abbreviation)
export CLIENT_VALID_DAYS=30												# Days Client Cert is valid	


## Docker Only 
#
export DOCKER_SUBNET="172.20.0.0/24"    # Docker subnet


## Install Options -- DO NOT CHANGE THESE
#       
export TAK_ALIAS=__TAK_ALIAS           		# Reference name and release pathname
export TAK_URI=__TAK_URI               		# FQDN/Hostname
export INSTALLER=__INSTALLER				# Installer type ("docker" or "ubuntu")
export VERSION=__VERSION					# TAK release version; derived from TAK installer


## Derived Settings
#
conf_expand