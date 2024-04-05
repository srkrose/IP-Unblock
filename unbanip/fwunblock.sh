#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1

function fw_unblock() {
    result=$(csf -dr $ip | grep "LOGDROPOUT")

    if [[ ! -z "$result" ]]; then
        echo "$(date +"%F %T") CSF Unblocked $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

        echo "CSF IP Unblocked"
    else
        echo "CSF IP cannot Unblock"
    fi
}

fw_unblock
