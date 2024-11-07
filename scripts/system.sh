#!/bin/bash

SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source ${SCRIPT_PATH}/functions.inc.sh

conf ${1}

msg $info "\nPerforming TAK Server ${2}:\n"

if [[ "${INSTALLER}" == "docker" ]];then 
	docker_compose
	COMPOSE_FILE="${ROOT_PATH}/release/${1}/docker-compose.yml"

	if [[ "$2" == "start" || "$2" == "restart" ]];then
	    if ${DOCKER_COMPOSE} -f ${COMPOSE_FILE} ps | grep -q 'Up';then
	    	${DOCKER_COMPOSE} -f ${COMPOSE_FILE} restart
		else
		    ${DOCKER_COMPOSE} -f ${COMPOSE_FILE} up -d

		    ## Sometimes the container does not come up happy
		    #  with no specific error logs indicating why
		    sleep 10
		    ${DOCKER_COMPOSE} -f ${COMPOSE_FILE} restart tak-server
		fi
	elif [[ "$2" == "stop" ]];then
	    ${DOCKER_COMPOSE} -f "$COMPOSE_FILE" stop ${3}
	else
	    ${DOCKER_COMPOSE} -f "$COMPOSE_FILE" ps
	fi
else 
	systemctl ${2} takserver
fi

echo

if [[ "$2" == "start" || "$2" == "restart" ]];then
	source ${ROOT_PATH}/scripts/server-check.sh ${1}
fi