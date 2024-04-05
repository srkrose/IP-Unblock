#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1

function ch_reason() {
    blacklist=$(whmapi1 read_cphulk_records list_name='black' | grep "$ip")

    history=$(whmapi1 get_cphulk_excessive_brutes | grep -B 3 -A 3 "$ip" | awk '!seen[$0]++')

    if [[ ! -z "$blacklist" ]]; then
        echo "Reason:"

        reason=$(egrep "$ip" $svrlogs/cphulk/iplist/* | cut -d' ' -f2-)

        echo "$reason"

        read -p "Remove from cPHulk Blacklist (y/n)? " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            sh $scripts/unbanip/chunblock.sh $ip

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
            sh $scripts/unbanip/chunblock.sh $ip

        fi

    else
        echo "cPHulk No records found"
    fi
}

ch_reason
