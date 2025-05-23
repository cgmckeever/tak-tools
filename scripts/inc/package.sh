SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")
source ${SCRIPT_PATH}/inc/functions.sh

TAK_PACKAGE_PATH=${ROOT_PATH}/tak-pack

msg $info "\n\nMoving TAK packages from /tmp ...\n\n"
cp /tmp/*tak* ${TAK_PACKAGE_PATH} 2>/dev/null

MATCH_PATH=${TAK_PACKAGE_PATH}
MATCH_PATTERN="*tak*"
MATCHES=(${MATCH_PATH}/${MATCH_PATTERN})

if [[ ${#MATCHES[@]} -eq 0 || ( ${#MATCHES[@]} -eq 1 && ${MATCHES[0]} == "${MATCH_PATH}/${MATCH_PATTERN}" ) ]]; then
  msg $danger "No 'TAK' installers found ..."
  msg $danger "Download from tak.gov and transfer to '${TAK_PACKAGE_PATH}/'\n\n"
  exit
fi

msg $success "TAK packages found in ${TAK_PACKAGE_PATH}/:"
for i in "${!MATCHES[@]}";do
  msg $info "$((i + 1)). $(basename "${MATCHES[i]}")"
done

prompt "Which TAK install package number:" TAK_PACKAGE_SELECTION

if [[ "${TAK_PACKAGE_SELECTION}" -gt 0 && "${TAK_PACKAGE_SELECTION}" -le "${#MATCHES[@]}" ]];then
 	TAK_PACKAGE="${MATCHES[$((TAK_PACKAGE_SELECTION - 1))]}"
 	TAK_PACKAGE=$(basename ${TAK_PACKAGE})

	if [[ "${TAK_PACKAGE}" == *.zip ]];then
		INSTALLER="docker"
	elif [[ "${TAK_PACKAGE}" == *.deb ]];then
		INSTALLER="ubuntu"
	else
		msg $danger "Unknown installer package ${TAK_PACKAGE}"
		exit 1
	fi

	VERSION=$(echo "${TAK_PACKAGE}" | sed -E 's/.*[_-]([0-9]+\.[0-9]+)-RELEASE.*/\1/')
	msg $success "Using TAK ${VERSION} ${INSTALLER} install: ${TAK_PACKAGE}"
	
else
  	msg $danger "\n\n------------ No TAK Server Package found matching selection."
  	msg $warn "\n------------ Please run the script again and choose a valid number. \n\n"
	exit
fi