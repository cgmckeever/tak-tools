####
#
#           These Defaults work; 
#           unless noted, you can change them as needed
#
####


## TAK
#
export TAK_DB_ALIAS=__TAK_DB_ALIAS    				# hostname/ip/fqdn for DB connection
export TAK_ADMIN=tak-admin              			# TAK Web Admin
export TAK_COT_PORT=8089               				# TAK API Port [not fully tested if a change works]


## LetsEncrypt (optional)
#
export LETSENCRYPT=__LE_ENABLE                   	# enable LE port 8446 cert (required for ITAK)
export LE_EMAIL=__LE_EMAIL                   		# email to send LetsEncrypt validations
export LE_VALIDATOR=__LE_VALIDATOR             		# validator type ("web" or "dns")


## Certificate info - Change these as needed
#
export CA_PASS=__CA_PASS      						# CA Password
export CERT_PASS=__CERT_PASS						# User Cert Password
export ORGANIZATION=__ORGANIZATION					# CA organization name
export ORGANIZATIONAL_UNIT=__ORGANIZATIONAL_UNIT 	# CA organization unit
export CITY=__CITY									# CA city
export STATE=__STATE								# CA state
export COUNTRY=__COUNTRY							# CA country (2 letter abbreviation)
export CLIENT_VALID_DAYS=__CLIENT_VALID_DAYS		# Days Client Cert is valid	


## Docker Only 
#
export DOCKER_SUBNET="172.20.0.0/24"    			# Docker subnet


## Install Options -- DO NOT CHANGE THESE
#       
export TAK_ALIAS=__TAK_ALIAS           				# Reference name and release pathname
export TAK_URI=__TAK_URI               				# FQDN/Hostname
export TAK_DB_PASS=__TAK_DB_PASS            		# Database password
export TAK_PACKAGE=__TAK_PACKAGE					# TAK package
export INSTALLER=__INSTALLER						# Installer type ("docker" or "ubuntu")
export VERSION=__VERSION							# TAK release version; derived from TAK installer

