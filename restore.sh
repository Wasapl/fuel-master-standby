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

#change astute.yaml in tarball

#restore backup
octane fuel-restore --from $DIR_BACKUP/$STATE_FILE
octane fuel-repo-restore --from $DIR_BACKUP/$REPO_FILE
#delete backup files (optionaly)