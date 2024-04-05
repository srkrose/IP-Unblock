#!/bin/bash

source /home/sample/scripts/dataset.sh

servername=""

function check_svr() {
    read -p "Server (1001/scan/4/5/6/7)? " svrnum

    if [[ $svrnum -eq 1001 ]]; then
        servername="whm1001"

    elif [[ "$svrnum" == "scan" ]]; then
        servername="node1scan"

    elif [[ $svrnum -eq 4 ]]; then
        servername="node234"

    elif [[ $svrnum -eq 5 ]]; then
        servername="node235"

    elif [[ $svrnum -eq 6 ]]; then
        servername="node236"

    elif [[ $svrnum -eq 7 ]]; then
        servername="node237"

    else
        echo "Invalid Server"
    fi

    server_ip
}

function server_ip() {
    if [[ ! -z "$servername" ]]; then
        serverip=$(cat $scripts/svrips.txt | grep "$servername" | awk -F':' '{print $NF}' | head -1)

        remote_con
    fi
}

function remote_con() {
    read -p "IP Address (XXX.XXX.XXX.XXX)? " ip

    if [[ ! -z "$ip" ]]; then
        command="sh $scripts/unbanip/ipreason.sh $ip"

        sudo ssh -t root@$serverip -p $svrport -i $sshkey "$command"

    else
        echo "IP Address is empty"
    fi
}

check_svr
