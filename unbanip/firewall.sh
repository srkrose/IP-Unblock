#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1

function ip_unblock() {
    search=$(csf -g $ip | tail -1 | grep "csf.deny:\|cphulk")

    if [[ ! -z "$search" ]]; then
        echo "Reason:"

        log_data

        read -p "Remove from CSF Deny List (y/n)? " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            result=$(csf -dr $ip | grep "LOGDROPOUT")

            if [[ ! -z "$result" ]]; then
                echo "$(date +"%F %T") CSF Unblocked $ip" >>$svrlogs/unbanip/unblock/unban_$logtime.txt

                echo "CSF IP Unblocked"
            else
                echo "CSF IP cannot Unblock"
            fi
        fi

    else
        echo "CSF No record found"
    fi
}

function log_data() {
    type=$(echo "$search" | awk '{print $5}' | sed 's/(//;s/)//')

    if [[ "$type" == "imapd" || "$type" == "pop3d" ]]; then
        sh $scripts/unbanip/maillog.sh $ip $type

    elif [[ "$type" == "smtpauth" ]]; then
        sh $scripts/unbanip/eximlog.sh $ip $type

    elif [[ "$type" == "eximsyntax" ]]; then
        sh $scripts/unbanip/eximsyntax.sh $ip $type

    elif [[ "$type" == "cpanel" ]]; then
        sh $scripts/unbanip/loginlog.sh $ip $type

    elif [[ "$type" == "ftpd" ]]; then
        sh $scripts/unbanip/ftpdlog.sh $ip $type

    elif [[ "$type" == "sshd" ]]; then
        sh $scripts/unbanip/sshdlog.sh $ip $type

    elif [[ "$type" == "mod_security" ]]; then
        sh $scripts/unbanip/modseclog.sh $ip $type

    else
        echo "Unknown type: $type"

    fi
}

ip_unblock
