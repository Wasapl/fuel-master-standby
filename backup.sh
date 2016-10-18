#!/bin/bash -x

ROOT=$(dirname `readlink -f $0`)
source $ROOT/config.sh

#TODO check octane installed
type octane >/dev/null 2>&1
if [ $? -eq 1 ]; then
	echo 'There is no fuel-octane. Run yum install fuel-octane first.'
	exit 1
fi

if [ -d $BACKUP_DIR ]; then
	# should check content of BACKUP_DIR prior to run next command 
	rm -rf $BACKUP_DIR
fi

mkdir -p $BACKUP_DIR

# Verify that no installations are in progress in any of your OpenStack environments.
if not $(fuel task|awk -F'|' 'NR>2&&($2~/pending/||$2~/running/){exit 1}'); then
    echo 'There is tasks running or pending in Nailgun. Aborting backup.'
fi

# do octane backup
echo 'No tasks running in Nailgun.\nRun backup.'
octane fuel-backup --to $BACKUP_DIR/fuel-backup.8.0.tar.gz
octane fuel-repo-backup --full --to $BACKUP_DIR/fuel-repo-backup.8.0.tar.gz

#TODO private keys
scp $BACKUP_DIR/fuel-backup.8.0.tar.gz $STANDBY_IP:/$STANDBY_DIR/$DATE/
scp $BACKUP_DIR/fuel-repo-backup.8.0.tar.gz $STANDBY_IP:$STANDBY_DIR/$DATE/