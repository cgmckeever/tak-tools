#!/bin/bash

export ACTIVE_SSL=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$ACTIVE_SSL" | tr -d '\r')

export IP=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$IP" | tr -d '\r')
export TAK_URL=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$URL" | tr -d '\r')

export CAPASS=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$CAPASS" | tr -d '\r')
export PASS=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$PASS" | tr -d '\r')

export TAK_ALIAS=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$TAK_ALIAS" | tr -d '\r')
export TAK_COT_PORT=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$TAK_COT_PORT" | tr -d '\r')
export TAK_CA=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$TAK_CA" | tr -d '\r')

export COUNTRY=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$COUNTRY" | tr -d '\r')
export STATE=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$STATE" | tr -d '\r')
export CITY=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$CITY" | tr -d '\r')
export ORGANIZATION=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$ORGANIZATION" | tr -d '\r')
export ORGANIZATIONAL_UNIT=$($DOCKER_COMPOSE -f ${DOCKER_COMPOSE_YML} exec tak-server bash -c "echo \$ORGANIZATIONAL_UNIT" | tr -d '\r')