#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

#===============================================================================
# Basic settings ---------------------------------------------------------------
SRCPATH=/mnt/DATA_SSD                       # Root direcoty
SNAP_PATH=/mnt/DATA_SSD/.snapshot           # Directory for snapshot
SNAP_PATERN=@GMT-$(date +%Y.%m.%d_%H.%M.%S) # Get current time

# Creating array of source directory
declare -a \
    DIR_LIST=(
        workplace
        picture
    )

#===============================================================================
# snapshot start ---------------------------------------------------------------
for DIR in ${DIR_LIST[@]}; do
    btrfs subvolume snapshot -r \
        $SRCPATH/@$DIR \
        $SNAP_PATH/@SN_$DIR/$SNAP_PATERN >>$SNAP_PATH/$DIR\_SN.log
    sync
done

# The snapshot is created
exit 0
