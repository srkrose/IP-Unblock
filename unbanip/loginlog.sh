#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /usr/local/cpanel/logs/login_log | grep "$ip" | grep "FAILED LOGIN" | awk '{print $1,$2,$5,$6,$8,$9}' | sed 's/[][]//g;s/"//' | awk '{printf "%-19s %-17s %-19s %-13s %-22s %-50s\n","DATE: "$1,"TIME: "$2,"LOGIN: "$3,"TYPE: "$6,"IP: "$4,"USER: "$5}' | sort | uniq -c >>$temp/$type-unban_$time.txt
}

function filter_log() {
	if [ -r $temp/$type-unban_$time.txt ] && [ -s $temp/$type-unban_$time.txt ]; then
		today=$(date +"%F")
		yesterday=$(date -d 'yesterday' +"%F")

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
