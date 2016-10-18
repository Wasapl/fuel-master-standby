#!/bin/bash -x

BACKUP_DIR=/var/log/backup
STANDBY_IP=172.16.0.2
STANDBY_DIR=/var/log/backup

DATE=`date +%F`


#TODO check octane installed

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
scp $BACKUP_DIR/fuel-backup.8.0.tar.gz $STANDBY_IP:/backup/$DATE/
scp $BACKUP_DIR/fuel-repo-backup.8.0.tar.gz $STANDBY_IP:/backup/$DATE/