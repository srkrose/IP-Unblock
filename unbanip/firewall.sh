#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function fw_reason() {
        echo "Reason:"

        log_data

        read -p "Remove from CSF Deny List (y/n)? " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            sh $scripts/unbanip/fwunblock.sh $ip

        fi
}

function log_data() {
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
        echo "No logs available for this category"

    fi
}

fw_reason
