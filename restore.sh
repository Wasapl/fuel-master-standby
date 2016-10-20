#!/bin/bash 

BACKUP_DIR=/var/backup/octane/
STANDBY_IP=67.217.83.5
STANDBY_DIR=/var/backup/octane/
MASTER_HOSTNAME=fuel1
STANDBY_HOSTNAME=fuel2
PASSWORD=
DATE=`date +%F`

STATE_FILE=fuel-backup.8.0.tar.gz
REPO_FILE=fuel-repo-backup.8.0.tar.gz

LOG_FILE=/var/log/master_standby.log


exec 1<&-
exec 2<&-
exec 1<>$LOG_FILE
exec 2>&1

#TODO check octane installed
set +e
type octane >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo 'There is no fuel-octane. Run "yum install fuel-octane" first.'
    exit 1
fi
set -e

#check latest backup exist
LAST_DIR=`ls -t $STANDBY_DIR -1|head -n 1`
if ! [ -d $STANDBY_DIR/$LAST_DIR ]; then
    echo "Unexpected files in $STANDBY_DIR. Aborting."
    exit 1
fi
if ! [ -s $STANDBY_DIR/$LAST_DIR/$STATE_FILE ]; then
    echo "File $STANDBY_DIR/$LAST_DIR/$STATE_FILE do not exist. Aborting."
    exit 1
fi
if ! [ -s $STANDBY_DIR/$LAST_DIR/$REPO_FILE ]; then
    echo "File $STANDBY_DIR/$LAST_DIR/$REPO_FILE do not exist. Aborting."
    exit 1
fi


#change astute.yaml in tarball
if [ -s astute/astute.yaml ]; then
    rm astute/astute.yaml
fi
if ! [ -d astute ]; then
    mkdir astute 2>/dev/null
fi

tar -Oxzf $STANDBY_DIR/$LAST_DIR/$STATE_FILE astute/astute.yaml | python -c "import sys;import yaml; data = yaml.load(sys.stdin);data['HOSTNAME']=\"${STANDBY_HOSTNAME}\"; yaml.dump(data, sys.stdout);"  >astute/astute.yaml

if [ -s astute/astute.yaml ]; then
    tar_file=$STANDBY_DIR/$LAST_DIR/${STATE_FILE%.*}
    gunzip $STANDBY_DIR/$LAST_DIR/$STATE_FILE
    tar -uf $tar_file astute/astute.yaml
    gzip $tar_file
else
    echo "Astute.yaml modify was unsuccessful. Aborting."
    exit 1
fi


#restore backup
octane fuel-restore --from $STANDBY_DIR/$LAST_DIR/$STATE_FILE --admin-password $PASSWORD
octane fuel-repo-restore --from $STANDBY_DIR/$LAST_DIR/$REPO_FILE

#delete backup files (optionaly)
