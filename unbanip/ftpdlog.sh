#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/messages | grep "$ip" | grep "pure-ftpd:" | grep "Authentication failed for user" | awk '{gsub(/\(\?@|\)/, "", $6); gsub(/\[|\]/, "", $NF); printf "%-15s %-17s %-22s %-50s\n","DATE: "$1" "$2,"TIME: "$3,"IP: "$6,"USER: "$NF}' | uniq -c >>$temp/$type-unban_$time.txt
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
