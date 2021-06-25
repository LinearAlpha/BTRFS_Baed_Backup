#!/bin/sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin

#===============================================================================
# Basic settings
current_date=$(date +%Y_%m_%d) # Setting for current date
BACKUPHOME=/mnt/Backup/rsync   # Setting backup home directory
# directory increament back up
Changes_dir=$BACKUPHOME/changes_day/$current_date

mkdir -p $Changes_dir/log # Creating directory for back up

# Find direcory more then week ago, and select
find $BACKUPHOME/changes_day -maxdepth 1 -type d -ctime +5 \
  -exec rm -rvf {} + >$Changes_dir/log/del.log

#===============================================================================
# Backup start
for DIR in DATA_SSD DATA; do
  # Setting is fallows
  # 0. rsync
  # 1, 2. Basic Setting
  # 3. Directory for changes
  # 4. Files/Folder exculde from back up
  # 5. Creating log for the back up
  # 6 .Backup directory and destination
  rsync \
    -avh --progress --force --ignore-errors --delete --delete-excluded \
    --backup \
    --backup-dir=$Changes_dir \
    --exclude-from=$BACKUPHOME/exclude_files-$DIR.txt \
    --log-file=$Changes_dir/log/$DIR-Back.log \
    /mnt/$DIR $BACKUPHOME/current
done

# Backup is complete
exit 0
