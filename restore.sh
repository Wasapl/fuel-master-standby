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
if [ -s astute/astute.yaml]; then
    rm astute/astute.yaml
fi
mkdir astute 2>/dev/null

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
#octane fuel-restore --from $STANDBY_DIR/$LAST_DIR/$STATE_FILE --admin-password <>
#octane fuel-repo-restore --from $STANDBY_DIR/$LAST_DIR/$REPO_FILE

#delete backup files (optionaly)
