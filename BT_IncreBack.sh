#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

##==============================================================================
## Cheking privilege -----------------------------------------------------------
# Scrip requried to run on rooot, or sudo user
if [[ $EUID -ne 0 ]]; then
    echo
    echo -e "\e[1;31m !-------------------------------------------------!\e[0m"
    echo -e "\e[1;31m ! Standared user detected.                        !\e[0m"
    echo -e "\e[1;31m ! Run script a Sudo user account (no sudo).       !\e[0m"
    echo -e "\e[1;31m ! Exiting Script                                  !\e[0m"
    echo -e "\e[1;31m !-------------------------------------------------!\e[0m"
    echo
    #sh_credits
    exit 2
fi

##==============================================================================
## Basic settings --------------------------------------------------------------
BT_ROOT_D=/mnt/DATA_SSD/                    # Root Mount point of souece
BT_ROOT_B=/mnt/Backup/                      # Root Mount point of backup
SRCPATH=/mnt/DATA_SSD                       # Root of source dir
SNAP_PATH_T=/mnt/DATA_SSD/.snapshot         # Temperate dir for snapshot
SNAP_PATH_I=/mnt/Backup/incremental         # Backup destination
TMP_TIME=$(date +%Y.%m.%d_%H.%M.%S)
SNAP_PATERN=@CST-$TMP_TIME # Get current time

# List fo source directories
declare -a \
    DIR_LIST=(
        workplace
        picture
    )

##==============================================================================
## Backup start-----------------------------------------------------------------

# Print current time for snapshot
printf "\n=================================================\n"
printf "Snapshot time: $TMP_TIME===============\n"

# If it is 5 am, add DATA to backup and delect old snapshots
if [ "$(date +%M)" == "00" ]; then
    DIR_LIST=(
        ${DIR_LIST[@]}
        DATA
    )
    if [ "$(date +%H)" == "05" ]; then
        # Costom python program auto delect shanpshot
        # Find and delect snapshot more then month for each directory
        for DIR in ${DIR_LIST[@]}; do
            printf "====Delecting old sanpshot $DIR on $TMP_TIME\n"
            $(dirname "$0")/snap_del -s $SNAP_PATH_I/@SN_$DIR
            # Force a sync on a filesystem
        done
        # Synchronize cached writes to persistent storage
        btrfs filesystem sync $BT_ROOT_B
    fi
fi

for DIR in ${DIR_LIST[@]}; do
    tmp_sn=$SNAP_PATH_T/@SN_$DIR # Full tmp sn dir
    tmp_o=$(ls -A $tmp_sn/)      # Get old snapshot
    des=$SNAP_PATH_I/@SN_$DIR    # Full directory of destination
    # Perint current working directory
    printf "====Snapshot directory for $DIR\n"
    # Creating temperate snapshot before send to backup drive
    btrfs subvolume snapshot -r $SRCPATH/@$DIR $tmp_sn/$SNAP_PATERN
    # Force a sync on a filesystem
    btrfs filesystem sync $BT_ROOT_D
    # If directory is empty, send intial snapshot
    if [[ -z $tmp_o ]]; then
        btrfs send $tmp_sn/$SNAP_PATERN | btrfs receive $des
    else
        tmp_o=($tmp_sn/*)
        tmp_o=${tmp_o[-2]}
        # Send only difference
        btrfs send -p $tmp_o $tmp_sn/$SNAP_PATERN | btrfs receive $des
        # Delect temperate snapshot
        btrfs subvolume delete $tmp_o
    fi
    # Force a sync on a filesystem
    btrfs filesystem sync $BT_ROOT_D
    btrfs filesystem sync $BT_ROOT_B
done

# Exit scrip
exit 0
