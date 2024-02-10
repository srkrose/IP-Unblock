#!/bin/bash

source /home/sample/scripts/dataset.sh

servername=""

function check_svr() {
    read -p "Server Number (1/2/3/4/5)? " answer

    if [[ $answer -eq 1 ]]; then
        servername="whm1"

    elif [[ $answer -eq 2 ]]; then
        servername="node2"

    elif [[ $answer -eq 3 ]]; then
        servername="node3"

    elif [[ $answer -eq 4 ]]; then
        servername="node4"

    elif [[ $answer -eq 5 ]]; then
        servername="node5"

    else
        echo "Invalid Server"
    fi

    server_ip
}

function server_ip() {
    if [[ ! -z "$servername" ]]; then
        serverip=$(cat $scripts/svrips.txt | grep "$servername" | awk -F':' '{print $NF}' | head -1)

        ip_unblock
    fi
}

function ip_unblock() {
    read -p "IP Address (XXX.XXX.XXX.XXX)? " ip

    if [[ ! -z "$ip" ]]; then
        command="sh $scripts/unbanip/ipunblock.sh $ip"

        sudo ssh -t root@$serverip -p $svrport -i $sshkey "$command"

    else
        echo "IP Address is empty"
    fi
}

check_svr
