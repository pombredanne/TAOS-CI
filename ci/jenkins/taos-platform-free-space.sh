#!/usr/bin/env bash
# -----------------------------------------------------------------------------------------
# @author Geunsik Lim <geunsik.lim@samsung.com>
# @brief Check if your hard disk is nearly full.
# @description
# This script does a simple test to checke disk space.
# If a mounted partition is under certain quota(10GB), alert us via 1) email.
# -----------------------------------------------------------------------------------------

#------------------------------- configuration area ---------------------------------------
# partions to monitor disk free space
# /dev/sdc1 / (14GB, Ubuntu OS)
# /dev/sdb1 /var/www (04TB, CI partition)
mounted_folders="/ /var/www"

# email information
email_cmd="mailx"
email_recipient="geunsik.lim@samsung.com myungjoo.ham@samsung.com jijoon.moon@samsung.com sangjung.woo@samsung.com \
wook16.song@samsung.com jy1210.jung@samsung.com jinhyuck83.park@samsung.com hello.ahn@samsung.com \
sewon.oh@samsung.com kibeom.lee@samsung.com byoungo.kim@samsung.com "
email_subject="[aaci] Critical:  Your hard disk is nearly full.".
email_message=" Hi,\n\n Ooops. Your specified partitions ($mounted_folders) are almost full.\n\n $(df -h)\n\n For more details, visit https://github.sec.samsung.net/STAR/TAOS-Platform/issues/.\n\n $(date).\n from aaci.mooo.com.\n"
PART_QUOTA_GB=10

#------------------------------- code area -----------------------------------------------
# check package dependency
function check_package() {
    echo "Checking for $1..."
    which "$1" 2>/dev/null || {
      echo "Please install $1."
      exit 1
    }
}

# send e-mail if a partitions is almost full.
function email_on_failure(){
    echo -e "$email_message" | $email_cmd -v -s  "$email_subject" $email_recipient
}

# check dependency
check_package mailx
check_package df

# run

source /etc/environment

for dir in $mounted_folders; do
    PART_FREE_MB=`df -m --output=avail "$dir" | tail -n1` # df -m not df -h
    PART_FREE_GB=$(($PART_FREE_MB/1024))
    if [[ $PART_FREE_GB -lt $PART_QUOTA_GB ]]; then
        echo "[DEBUG] Oops. '$dir' is almost full. The available space is $PART_FREE_GB Gbytes."
        email_on_failure
        exit 4
    else
        echo "[DEBUG] Okay. '$dir' is not full. The available space is $PART_FREE_GB Gbytes."
    fi
done

# jenkins submit issue according "exit ***" value.
exit 0