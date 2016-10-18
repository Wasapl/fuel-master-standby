#!/bin/bash -x

BACKUP_DIR=/var/log/backup
STANDBY_IP=172.16.0.2
STANDBY_DIR=/var/log/backup
MASTER_HOSTNAME=fuel1
STANDBY_HOSTNAME=fuel2
DATE=`date +%F`

STATE_FILE=fuel-backup.8.0.tar.gz
REPO_FILE=fuel-repo-backup.8.0.tar.gz