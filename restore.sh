#!/bin/bash -x

ROOT=$(dirname `readlink -f $0`)
source $ROOT/config.sh

#TODO check octane installed
type octane >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo 'There is no fuel-octane. Run "yum install fuel-octane" first.'
    exit 1
fi

#check latest backup exist
LAST_DIR=`ls -t $STANDBY_DIR -1|head -n 1`
if ! [ -d $LAST_DIR ]; then
    echo "Unexpected files in $STANDBY_DIR. Aborting."
    exit 1
fi
if ! [ -s $DIR_BACKUP/$LAST_DIR/$STATE_FILE ]; then
    echo "File $DIR_BACKUP/$LAST_DIR/$STATE_FILE do not exist. Aborting."
    exit 1
fi
if ! [ -s $DIR_BACKUP/$LAST_DIR/$REPO_FILE ]; then
    echo "File $DIR_BACKUP/$LAST_DIR/$REPO_FILE do not exist. Aborting."
    exit 1
fi


#change astute.yaml in tarball
if [ -s astute/astute.yaml]; then
    rm astute/astute.yaml
fi
mkdir astute 2>/dev/null

tar -Oxzf $DIR_BACKUP/$LAST_DIR/$STATE_FILE astute/astute.yaml | python -c "import sys;import yaml; data = yaml.load(sys.stdin);data['HOSTNAME']=\"${STANDBY_HOSTNAME}\"; yaml.dump(data, sys.stdout);"  >astute/astute.yaml
tar -rzf $DIR_BACKUP/$LAST_DIR/$STATE_FILE astute/astute.yaml
if [ -s astute/astute.yaml ]; then
    tar -uzf $DIR_BACKUP/$LAST_DIR/$STATE_FILE astute/astute.yaml
else
    echo "Astute.yaml modify was unsuccessful. Aborting."
    exit 1
fi 


#restore backup
octane fuel-restore --from $DIR_BACKUP/$LAST_DIR/$STATE_FILE
octane fuel-repo-restore --from $DIR_BACKUP/$LAST_DIR/$REPO_FILE

#delete backup files (optionaly)
