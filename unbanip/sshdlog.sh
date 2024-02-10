#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/secure | grep "$ip" | grep -iv "pam_unix\|wp-toolkit\|127.0.0.1\|Bad protocol version\|sudo:" | grep "Invalid user\|Failed password for invalid user\|Did not receive identification string from\|Connection closed by" | awk '{for(i=1;i<=NF;i++) {if($i=="port") {if($6!="Did") printf "%-15s %-17s %-22s %-14s %-50s\n","DATE: "$1" "$2,"TIME: "$3,"IP: "$(i-1),"PORT: "$(i+1),"TYPE: "$6" "$7; else printf "%-15s %-17s %-22s %-14s %-50s\n","DATE: "$1" "$2,"TIME: "$3,"IP: "$(i-1),"PORT: "$(i+1),"TYPE: "$9" "$10}}}' | sort | uniq -c >>$temp/$type-unban_$time.txt
}

function filter_log() {
	if [ -r $temp/$type-unban_$time.txt ] && [ -s $temp/$type-unban_$time.txt ]; then
		today=$(date +"%b %-d")
		yesterday=$(date -d 'yesterday' +"%b %-d")

		data=$(cat $temp/$type-unban_$time.txt | grep "$today")

		if [[ -z "$data" ]]; then
			data=$(cat $temp/$type-unban_$time.txt | grep "$yesterday")

			if [[ ! -z "$data" ]]; then
				echo "$data" >>$svrlogs/unbanip/firewall/$type-unban_$time.txt

			else
				echo "$type: $ip - No log records found" >>$svrlogs/unbanip/firewall/$type-unban_$time.txt
			fi

		else
			echo "$data" >>$svrlogs/unbanip/firewall/$type-unban_$time.txt
		fi

		cat $svrlogs/unbanip/firewall/$type-unban_$time.txt
	fi
}

log_data

filter_log
