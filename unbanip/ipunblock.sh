#!/bin/bash

source /home/sample/scripts/dataset.sh

ipv4='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
ipv6='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

input=$1

function check_ip() {
    if [[ $input =~ $ipv4 || $input =~ $ipv6 ]]; then
        ip=$input

        ip_unblock
    else
        echo "Invalid IP"
    fi
}

function ip_unblock() {
    search=$(csf -g $ip | tail -1 | grep "csf.deny:\|cphulk")

    if [[ ! -z $search ]]; then
        type=$(echo "$search" | awk '{print $1}')

        if [[ "$type" == "csf.deny:" ]]; then
            echo "Blocked by Firewall:"
            echo "$search"

            sh $scripts/unbanip/firewall.sh $ip

        elif [[ "$type" == "filter" ]]; then
            echo "Blocked by cPHulk:"
            echo "$search"

            sh $scripts/unbanip/cphulk.sh $ip

        else
            echo "Unknown type:"
            echo "$search"
        fi

    else
        search=$(whmapi1 read_cphulk_records list_name='black' | grep "$ip")

        if [[ ! -z $search ]]; then
            echo "Blacklisted by cPHulk:"
            echo "$search"

            sh $scripts/unbanip/cphulk.sh $ip
            
        else
            echo "No records found"
        fi
    fi
}

check_ip
