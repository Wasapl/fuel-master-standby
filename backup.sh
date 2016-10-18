#!/bin/bash -x

DIR_BACKUP=/var/log/backup
STANDBY_IP=172.16.0.2
DATE=`date +%F`


#TODO check octane installed


mkdir -p $DIR_backup
# Verify that no installations are in progress in any of your OpenStack environments.
if not $(fuel task|awk -F'|' 'NR>2&&($2~/pending/||$2~/running/){exit 1}'); then
    echo 'There is tasks running or pending in Nailgun. Aborting backup.'
fi

# do octane backup
echo 'No tasks running in Nailgun.\nRun backup.'
octane fuel-backup --to $DIR_BACKUP/fuel-backup.8.0.tar.gz
octane fuel-repo-backup --full --to $DIR_BACKUP/fuel-repo-backup.8.0.tar.gz

#TODO private keys
scp $DIR_BACKUP/fuel-backup.8.0.tar.gz $STANDBY_IP:/backup/$DATE/
scp $DIR_BACKUP/fuel-repo-backup.8.0.tar.gz $STANDBY_IP:/backup/$DATE/