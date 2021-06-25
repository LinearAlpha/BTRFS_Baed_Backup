#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

#===============================================================================
# Basic settings ---------------------------------------------------------------
SRCPATH=/mnt/DATA_SSD                       # Root direcoty
SNAP_PATH=/mnt/DATA_SSD/.snapshot           # Directory for snapshot
SNAP_PATERN=@GMT-$(date +%Y.%m.%d_%H.%M.%S) # Get current time
DIR=DATA

#===============================================================================
# snapshot start ---------------------------------------------------------------
btrfs subvolume snapshot -r \
    $SRCPATH/@$DIR \
    $SNAP_PATH/@SN_$DIR/$SNAP_PATERN >>$SNAP_PATH/$DIR\_SN.log

# The snapshot is created
exit 0
