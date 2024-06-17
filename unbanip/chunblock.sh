#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
category=$2

function ch_unblock() {
    if [[ "$category" == "blacklist" ]]; then
        delist_ip

        flush_ip

        if [[ "$dresult" -eq 1 && "$fresult" -eq 1 ]]; then
            echo "$(date +"%F %T") cPHulk Delisted & Flushed $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

            echo "cPHulk IP Delisted & Flushed"

            add_ip

        else
            echo "cPHulk IP cannot Delist & Flush"
        fi

    else
        flush_ip

        if [[ "$fresult" -eq 1 ]]; then
            echo "$(date +"%F %T") cPHulk Flushed $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

            echo "cPHulk IP Flushed"

        else
            echo "cPHulk IP cannot Flush"
        fi
    fi
}

function delist_ip() {
    dresult=$(whmapi1 delete_cphulk_record list_name='black' ip=$ip | grep -i "result:" | awk '{print $2}')
}

function flush_ip() {
    fresult=$(whmapi1 flush_cphulk_login_history_for_ips ip=$ip | grep -i "result:" | awk '{print $2}')
}

function add_ip() {
    ccode=$(echo "$blacklist" | awk '{print $NF}')

    if [[ "$ccode" != "LK" ]]; then
        echo "$ip" >>$scripts/ipmonitor/staticip.txt

        echo "$ip IP added to Static IP list successfully"
    fi
}

ch_unblock
