#!/bin/bash

arch=$(dpkg --print-architecture)

TEMPLATE_PATH="${TOOLS_PATH}/templates"

color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m      # cyan
color success 92m   # green
color warning 93m   # yellow
color danger 91m    # red

NOW=$(date "+%Y.%m.%d-%H.%M.%S")

pause () {
    echo
    if [[ ! -z $1 ]]; then
        printf $info "\nThis is a break pause; should be removed: $1\n\n"
    fi
    read -s -p "Press Enter to resume setup... "
    echo
}