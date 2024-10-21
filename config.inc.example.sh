####
#
#           These Defaults work; 
#           unless noted, you can change them as needed
#
####


## Install Options -- DO NOT CHANGE THESE
#       
export TAK_ALIAS=__TAK_ALIAS           		# Reference name and release pathname
export TAK_URI=__TAK_URI               		# FQDN/Hostname
export INSTALLER=__INSTALLER
export VERSION=__VERSION


## Docker Only 
#
export DOCKER_SUBNET="172.20.0.0/24"    # Docker subnet


## TAK
#
export TAK_DB_ALIAS=__TAK_DB_ALIAS    	# hostname/ip/fqdn for DB connection
export TAK_ADMIN=tak-admin              # TAK Web Admin
export TAK_COT_PORT=8089               	# TAK API Port [not fully tested if a change works]


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
#############															#############
#####                 You can change below, but probably shouldnt             	#####               
#############															#############
export DB_CN=${TAK_DB_ALIAS} 							    			# Database Common Name (should match TAK connection URI)
export TAK_CN=${TAK_URI}                 	                			# TAK Common Name (should match connection URL)
export CA_PREFIX=${TAK_CN}								    			# Used for naming replacement
export TAK_ROOT_CA=${CA_PREFIX}-Root-CA-01 	                			# Root CA Name
export TAK_CA=${CA_PREFIX}-Intermediary-CA-01               			# Intermediate CA for client cert signing
export TAK_CA_FILE=$(echo "$TAK_CA" | sed "s/${CA_PREFIX}/takserver/g") # Do not change


## LetsEncrypt
#
export LETSENCRYPT="false"                                  # enable LE port 8446 cert (required for ITAK)
export LE_EMAIL="someone@somewhere.com"                     # email to send LetsEncrypt validations
export LE_VALIDATOR="dns"                     				# validator type "web" or "dns"