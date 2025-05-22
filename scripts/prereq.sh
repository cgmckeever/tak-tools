#!/bin/bash

export SCRIPT_PATH=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

echo "Select installation type:"
echo "1. Ubuntu"
echo "2. Docker"
read -p "Enter 1 or 2: " choice

case "$choice" in
  1)
    echo "Running Ubuntu prereq script..."
    bash ${SCRIPT_PATH}/ubuntu/prereq.sh
    ;;
  2)
    echo "Running Docker prereq script..."
    bash ${SCRIPT_PATH}/docker/prereq.sh
    ;;
  *)
    echo "Invalid choice. Please enter 1 or 2."
    exit 1
    ;;
esac