#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

#===============================================================================
# Cheking privilege ------------------------------------------------------------
# Scrip requried to run on rooot, or sudo user
if [[ $EUID -ne 0 ]]; then
    echo
    echo -e "\e[1;31m !----------------------------------------------!\e[0m"
    echo -e "\e[1;31m ! Standared user detected.                     !\e[0m"
    echo -e "\e[1;31m ! Run script a Sudo user account (no sudo).    !\e[0m"
    echo -e "\e[1;31m ! Exiting Script                               !\e[0m"
    echo -e "\e[1;31m !----------------------------------------------!\e[0m"
    echo
    #sh_credits
    exit 2
fi

#===============================================================================
# Basic settings ---------------------------------------------------------------
BACKUPHOME=/mnt/DATA/Full_bak            # Home directory of backup
current_date=$(date +%Y_%m_%d)              # Setting for current date
SNAP_PATERN=@GMT-$(date +%Y.%m.%d_%H.%M.%S) # Sanpshot patter (works wireeh WIN)
SNAP_PATH=$BACKUPHOME/.snapshot             # Directory for snapshot
LOG_DIR_B=$SNAP_PATH/log                    # Log directory base
LOG_DIR_C=$LOG_DIR_B/$current_date          # Log direcroty with currnet date

# Program that delecs snapshot longer then certaub period time
snDel=$(dirname "$0")/snap_del

# Creating array of source directory
declare -a \
    DIR_LIST=(
        DATA_SSD
        Media/BD
        Media/NewAnime
    )

mkdir -p $LOG_DIR_C # Creating Directory for log

#===============================================================================
# Delecting old log and backup (snapshot) --------------------------------------
# Delect snapshot more then 14 days
$snDel -s $SNAP_PATH -d months -n 3 >$LOG_DIR_C/snap_del.log

# Delect log more then 14 days
find $LOG_DIR_B/* -maxdepth 0 -type d -ctime +29 \
    -exec rm -rvf {} + >$LOG_DIR_C/del.log

##===============================================================================
## Backup start -----------------------------------------------------------------
## Create snapshot (incremental backup)
#btrfs subvolume snapshot -r \
#    $BACKUPHOME/current \
#    $SNAP_PATH/$SNAP_PATERN >>$LOG_DIR_C/snap.log
#sync

# Start copy from source  directory
for DIR in ${DIR_LIST[@]}; do
    # Setting is fallows
    # 0. rsync
    # 1. Basic Setting
    # 2. Files/Folder exculde from back up
    # 3. Creating log for the back up
    # 4 .Backup directory and destination
    rsync \
        -avh --progress --delete --force --ignore-errors --delete-excluded \
        --exclude-from=$SNAP_PATH/filter/exclude_files-$DIR.txt \
        --log-file=$LOG_DIR_C/$DIR-Back.log \
        /mnt/$DIR/ $BACKUPHOME/$DIR/
done

# Backup is complete
exit 0
