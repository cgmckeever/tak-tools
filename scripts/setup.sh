#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
export ROOT_PATH=$(realpath ${SCRIPT_PATH}/..)

source ${ROOT_PATH}/scripts/functions.inc.sh 

###########
#
#            HELPERS
#
##

letsencrypt (){
	if [ "$LETSENCRYPT" = "true" ];then
		msg $info "\nProcessing LetsEncrypt\n"
		if [[ ! ${TAK_URI} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ && ${TAK_URI} =~ \. ]];then
			if [ ! -d "/etc/letsencrypt/live/${TAK_URI}" ];then 
				msg $info "Requesting LetsEncrypt\n\n"
	        	${ROOT_PATH}/scripts/letsencrypt-request.sh ${TAK_ALIAS}
	    	else
	    		msg $success "Found existing LetsEncrypt cert bundle\n\n"
	    	fi 
	        ACTIVE_SSL=__LE_SIGNED
		else
			msg $danger "\nLetsEncrypt Error"
			msg $warn "${TAK_URI} does not appear to be a FQDN for LetsEncrypt\n\n"
			exit
		fi
    fi
}

takconf (){
	## Check for specific Version config template
	#
	CONFIG_TMPL="tak-conf/coreconfig/CoreConfig.${VERSION}.xml.tmpl"
	if [ ! -f "${CONFIG_TMPL}" ];then
		CONFIG_TMPL="tak-conf/coreconfig/CoreConfig.xml.tmpl"
	fi

	ACTIVE_SSL=${ACTIVE_SSL:-"__SELF_SIGNED"}

	sed -e "/<!-- ${ACTIVE_SSL}/d" \
		-e "/${ACTIVE_SSL} -->/d" \
		-e "s/__CA_PASS/${CA_PASS}/g" \
		-e "s/__CLIENT_VALID_DAYS/${CLIENT_VALID_DAYS}/g" \
		-e "s/__ORGANIZATIONAL_UNIT/${ORGANIZATIONAL_UNIT}/g" \
		-e "s/__ORGANIZATION/${ORGANIZATION}/g" \
		-e "s/__TAK_CA/${TAK_CA_FILE}/g" \
		-e "s/__TRUSTSTORE/${TAK_CA_FILE}/g" \
		-e "s/__CA_CRL/${TAK_CA_FILE}/g" \
		-e "s/__TAK_DB_ALIAS/${TAK_DB_ALIAS}/g" \
		-e "s/__TAK_DB_PASS/${DB_PASS}/g" \
		-e "s/__TAK_URI/${TAK_URI}/g" \
		-e "s/__TAK_COT_PORT/${TAK_COT_PORT}/g" \
		${CONFIG_TMPL} > ${TAK_PATH}/CoreConfig.xml
}

filesync (){
	mkdir -p ${TAK_PATH}/tak-tools/conf

	cp tak-scripts/* ${TAK_PATH}/tak-tools/
	cp tak-conf/*client* ${TAK_PATH}/tak-tools/conf
	
	cp tak-conf/setenv.sh ${TAK_PATH}/

	cp ${RELEASE_PATH}/config.inc.sh ${TAK_PATH}/tak-tools/config.inc.sh
}

###########
#
#            INSTALLER
#
##

## TAK Package unpack
#
TAK_PACKAGE_PATH=${ROOT_PATH}/tak-pack

msg $info "\n\nMoving TAK packages from /tmp ...\n\n"
cp /tmp/*tak* ${TAK_PACKAGE_PATH} 2>/dev/null

MATCH_PATH=${TAK_PACKAGE_PATH}
MATCH_PATTERN="*tak*"
MATCHES=(${MATCH_PATH}/${MATCH_PATTERN})

if [[ ${#MATCHES[@]} -eq 0 || ( ${#MATCHES[@]} -eq 1 && ${MATCHES[0]} == "${MATCH_PATH}/${MATCH_PATTERN}" ) ]]; then
  msg $danger "No 'tak' files found in directory '${TAK_PACKAGE_PATH}'\n\n"
  exit
fi

msg $success "TAK packages found in ${TAK_PACKAGE_PATH}/:"
for i in "${!MATCHES[@]}";do
  msg $info "$((i + 1)). $(basename "${MATCHES[i]}")"
done

prompt "Which TAK install package:" TAK_PACKAGE_SELECTION

if [[ "${TAK_PACKAGE_SELECTION}" -gt 0 && "${TAK_PACKAGE_SELECTION}" -le "${#MATCHES[@]}" ]];then
 	TAK_PACKAGE="${MATCHES[$((TAK_PACKAGE_SELECTION - 1))]}"

	if [[ "${TAK_PACKAGE}" == *.zip ]];then
		INSTALLER="docker"
	elif [[ "${TAK_PACKAGE}" == *.deb ]];then
		INSTALLER="ubuntu"
	else
		msg $danger "Unknown installer package ${TAK_PACKAGE}"
		exit 1
	fi

	VERSION=$(echo "${TAK_PACKAGE}" | sed -E 's/.*[_-]([0-9]+\.[0-9]+)-RELEASE.*/\1/')
	msg $success "Using TAK ${VERSION} ${INSTALLER} install: $(basename ${TAK_PACKAGE})"
	
else
  	msg $danger "\n\n------------ No TAK Server Package found matching selection."
  	msg $warn "\n------------ Please run the script again and choose a valid number. \n\n"
	exit
fi

## Release Name
#
HOSTNAME_DEFAULT=${HOSTNAME//\./-}
prompt "Name your TAK release alias [${HOSTNAME_DEFAULT}] :" TAK_ALIAS
TAK_ALIAS=${TAK_ALIAS:-${HOSTNAME_DEFAULT}}

## TAK URI 
#
prompt "What is the URI (FQDN, hostname, or IP) [${IP_ADDRESS}] :" TAK_URI
TAK_URI=${TAK_URI:-${IP_ADDRESS}}

## Passwords
#
passgen ${DB_PASS_OMIT}
DB_PASS=${PASSGEN}
#prompt "TAK Database Password: Default [${DB_PASS}] :" DB_PASS_INPUT
#DB_PASS=${DB_PASS_INPUT:-${DB_PASS}}

## Tear-Down/Clean-up
#
scripts/${INSTALLER}/tear-down.sh ${TAK_ALIAS}

RELEASE_PATH=${ROOT_PATH}/release/${TAK_ALIAS}
rm -rf ${RELEASE_PATH}
mkdir ${RELEASE_PATH}

TAK_PATH=${RELEASE_PATH}/tak

## Prep
#
echo
if [[ "${INSTALLER}" == "docker" ]];then 
	if ! java -version &> /dev/null;then
		scripts/jdk.sh
	fi

	TEMP_DIR=$(mktemp -d)
	unzip ${TAK_PACKAGE} -d ${TEMP_DIR}
	mv ${TEMP_DIR}/*/* ${RELEASE_PATH}
	rm -rf ${TEMP_DIR}

	TAK_DB_ALIAS=tak-database
else	
	mkdir -p /opt/tak
	ln -s /opt/tak ${TAK_PATH}

	TAK_DB_ALIAS=127.0.0.1
fi 

mkdir -p jdk/bin

info ${RELEASE_PATH} "---- TAK Info: ${TAK_ALIAS} ----" init
info ${RELEASE_PATH} "Install: ${INSTALLER}"
info ${RELEASE_PATH} "TAK Version: ${VERSION}"
info ${RELEASE_PATH} "TAK Pack: $(basename ${TAK_PACKAGE})"
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Hostname/URI: ${TAK_URI}" 
info ${RELEASE_PATH} ""
info ${RELEASE_PATH} "Database Info:"
info ${RELEASE_PATH} "  URI: ${TAK_DB_ALIAS}" 
info ${RELEASE_PATH} "  User: martiuser" 
info ${RELEASE_PATH} "  Password: ${DB_PASS}" 
info ${RELEASE_PATH} ""

## TAK-Tools Config
#
sed -e "s/__TAK_ALIAS/${TAK_ALIAS}/g" \
	-e "s/__TAK_URI/${TAK_URI}/g" \
	-e "s/__INSTALLER/${INSTALLER}/g" \
	-e "s/__VERSION/$VERSION}/g" \
	-e "s/__TAK_DB_ALIAS/$TAK_DB_ALIAS/g" \
	config.inc.example.sh > ${RELEASE_PATH}/config.inc.sh

msg $warn "\nUpdate the config: ${RELEASE_PATH}/config.inc.sh"

prompt "Do you want to inline edit the conf with vi [y/N]?" EDIT_CONF
if [[ ${EDIT_CONF} =~ ^[Yy]$ ]];then
	vi ${RELEASE_PATH}/config.inc.sh
fi

source ${RELEASE_PATH}/config.inc.sh

## LetsEncrypt and CoreConfig Management
#
letsencrypt 
takconf

## Install
#
if [[ "${INSTALLER}" == "docker" ]];then 
	filesync
	scripts/cert-gen.sh ${TAK_ALIAS}
	scripts/docker/compose.sh ${TAK_ALIAS}
else
	apt install -y ${TAK_PACKAGE}
  usermod --shell /bin/bash tak

  filesync
  scripts/cert-gen.sh ${TAK_ALIAS}

	chown -R tak:tak /opt/tak
	systemctl enable takserver
fi

## Init
#
scripts/init.sh ${TAK_ALIAS}



