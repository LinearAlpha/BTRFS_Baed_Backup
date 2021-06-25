#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

#===============================================================================
# Basic settings ---------------------------------------------------------------
SRCPATH=/mnt/DATA_SSD/.snapshot # Base directory of snapshot
LOG_FILE=$SRCPATH/snap_del.log  # Log for the delection

# Program that delecs snapshot longer then certaub period time
snDel=$(dirname "$0")/snap_del

# Creating array of source directory
declare -a \
    DIR_LIST=(
        workplace
        picture
        DATA
    )

#===============================================================================
# Delection start --------------------------------------------------------------
for DIR in ${DIR_LIST[@]}; do
    # Find snapshot longer then month ago
    $snDel -s $SRCPATH/@SN_$DIR/ >>$LOG_FILE
done

# Safefly ecxit
exit 0
