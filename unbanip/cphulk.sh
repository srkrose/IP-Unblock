#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function ch_reason() {
    blacklist=$(whmapi1 read_cphulk_records list_name='black' | grep "$ip")

    if [[ ! -z "$blacklist" ]]; then
        category="blacklist"

        reason=$(egrep "$ip" $svrlogs/cphulk/iplist/* | cut -d' ' -f2-)

        ch_unblock

    else
        cpbrute=$(whmapi1 get_cphulk_brutes | grep "$ip")
        exbrute=$(whmapi1 get_cphulk_excessive_brutes | grep "$ip")
        flogin=$(whmapi1 get_cphulk_failed_logins | grep "$ip")
        ubrute=$(whmapi1 get_cphulk_user_brutes | grep "$ip")

        category="history"

        if [[ ! -z "$cpbrute" ]]; then
            reason=$(whmapi1 get_cphulk_brutes | awk '/^data:/ {p=1; next} /^metadata:/ {p=0} p {print}' | awk '/^ *- *$/ {if (record != "") {print record; record=""}} /^[^-]/ {sub(/^ +/, "", $0); if (record == "") {record = $0} else {record = record " " $0}} END {if (record != "") {print record}}' | { read first_line; echo "$first_line"; grep "$ip"; })

            ch_unblock

        elif [[ ! -z "$exbrute" ]]; then
            reason=$(whmapi1 get_cphulk_excessive_brutes | awk '/^data:/ {p=1; next} /^metadata:/ {p=0} p {print}' | awk '/^ *- *$/ {if (record != "") {print record; record=""}} /^[^-]/ {sub(/^ +/, "", $0); if (record == "") {record = $0} else {record = record " " $0}} END {if (record != "") {print record}}' | { read first_line; echo "$first_line"; grep "$ip"; })

            ch_unblock

        elif [[ ! -z "$flogin" ]]; then
            reason=$(whmapi1 get_cphulk_failed_logins | awk '/^data:/ {p=1; next} /^metadata:/ {p=0} p {print}' | awk '/^ *- *$/ {if (record != "") {print record; record=""}} /^[^-]/ {sub(/^ +/, "", $0); if (record == "") {record = $0} else {record = record " " $0}} END {if (record != "") {print record}}' | { read first_line; echo "$first_line"; grep "$ip"; })

            ch_unblock

        elif [[ ! -z "$ubrute" ]]; then
            reason=$(whmapi1 get_cphulk_user_brutes | awk '/^data:/ {p=1; next} /^metadata:/ {p=0} p {print}' | awk '/^ *- *$/ {if (record != "") {print record; record=""}} /^[^-]/ {sub(/^ +/, "", $0); if (record == "") {record = $0} else {record = record " " $0}} END {if (record != "") {print record}}' | { read first_line; echo "$first_line"; grep "$ip"; })

            ch_unblock

        else
            echo "cPHulk No records found"
        fi
    fi
}

function ch_unblock() {
    if [[ "$type" == "cphulk" ]]; then
        echo "Blocked by cPHulk:"
        
    fi

    echo "Reason:"

    echo "$reason"

    if [[ "$category" == "blacklist" ]]; then
        read -p "Remove from cPHulk Blacklist (y/n)? " answer
    else
        echo "$reason" >>$svrlogs/unbanip/cphulk/$category-unban_$time.txt

        read -p "Flush from cPHulk History (y/n)? " answer
    fi

    if [[ $answer == "y" || $answer == "Y" ]]; then
        sh $scripts/unbanip/chunblock.sh $ip $category
    fi
}

ch_reason
