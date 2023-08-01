#!/bin/bash

WORK_DIR=~/tak-server
rm -rf $WORK_DIR
mkdir -p $WORK_DIR

unzip /tmp/takserver*.zip -d ${$WORK_DIR}/; \
mv tak-server/tak* ${$WORK_DIR}/release;
chown -R $USER:$USER ${$WORK_DIR}


TAKADMIN=tak-admin
TAKADMIN_PASS=$(pwgen -cvy1 25)

PG_PASS=$(pwgen -cvy1 25)

DEFAULT_NIC=$(route | grep default | awk '{print $8}')