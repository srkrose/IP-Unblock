#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1

function ip_unblock() {
    blacklist=$(whmapi1 read_cphulk_records list_name='black' | grep "$ip")

    history=$(whmapi1 get_cphulk_excessive_brutes | grep -B 3 -A 3 "$ip" | awk '!seen[$0]++')

    if [[ ! -z "$blacklist" ]]; then
        echo "Reason:"

        reason=$(egrep "$ip" $svrlogs/cphulk/iplist/*)

        echo "$reason"

        read -p "Remove from cPHulk Blacklist (y/n)? " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            delist_ip

            flush_ip

            if [[ "$dresult" -eq 1 && "$fresult" -eq 1 ]]; then
                echo "$(date +"%F %T") cPHulk Delisted $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

                echo "cPHulk IP Delisted"

                add_ip
            else
                echo "cPHulk IP cannot Delist"
            fi
        fi

    elif [[ -z "$blacklist" && ! -z "$history" ]]; then
        echo "Reason:"

        whois=$(echo "$history" | awk '{if($1=="country_code:") print $2}')
        note=$(echo "$history" | awk '{if($1=="notes:") print}' | awk '{$1=""; print}' | sed 's/^[[:space:]]*//')

        echo "$ip ($whois): $note"

        type="cphulkd"

        sh $scripts/unbanip/cphulkdlog.sh $ip $type

        read -p "Flush from cPHulk History (y/n)? " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            flush_ip

            if [[ "$fresult" -eq 1 ]]; then
                echo "$(date +"%F %T") cPHulk Flushed $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

                echo "cPHulk IP Flushed"
            else
                echo "cPHulk IP cannot Flush"
            fi
        fi

    else
        echo "cPHulk No records found"
    fi
}

function delist_ip() {
    dresult=$(whmapi1 delete_cphulk_record list_name='black' ip=$ip | grep -i "result:" | awk '{print $2}')
}

function flush_ip() {
    fresult=$(whmapi1 flush_cphulk_login_history_for_ips ip=$ip | grep -i "result:" | awk '{print $2}')
}

function add_ip() {
    read -p "Add to Static IP list (y/n)? " answer

    if [[ $answer == "y" || $answer == "Y" ]]; then
        echo "$ip" >>$scripts/ipmonitor/staticip.txt

        echo "$ip IP added to Static IP list successfully"
    fi
}

ip_unblock
