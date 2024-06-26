#!/bin/bash

source /home/sample/scripts/dataset.sh

ipv4='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
ipv6='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

input=$1

function check_ip() {
    if [[ $input =~ $ipv4 || $input =~ $ipv6 ]]; then
        ip=$input

        ip_reason
    else
        echo "Invalid IP"
    fi
}

function ip_reason() {
    search=$(csf -g $ip | tail -1 | grep -v "csf.allow\|No matches found")

    if [[ ! -z $search ]]; then
        type=$(echo "$search" | awk '{print $1}')

        if [[ "$type" == "filter" ]]; then
            echo "Blocked by cPHulk:"
            echo "$search"

            type="firewall"

            sh $scripts/unbanip/cphulk.sh $ip $type

        else
            echo "Blocked by Firewall:"
            echo "$search"

            type=$(echo "$search" | awk '{print $5}' | sed 's/(//;s/)//')

            sh $scripts/unbanip/firewall.sh $ip $type
        fi

    else
        type="cphulk"
        
        sh $scripts/unbanip/cphulk.sh $ip $type
    fi
}

check_ip
