#!/bin/bash

CERT_PATH="${TAK_PATH}/certs"
FILE_PATH="${CERT_PATH}/files"

TAK_SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")

# TAK symbols from this list [-_!@#$%^&*(){}[]+=~`|:;<>,./?]
PASS_OMIT="&$,.~<>/\'\`\""
PADS="abcdefghijklmnopqrstuvwxyz"
PAD1=${PADS:$(( RANDOM % ${#PADS} )) : 1}
PAD2=${PADS:$(( RANDOM % ${#PADS} )) : 1}