#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/exim_mainlog | grep "$ip" | grep "Incorrect authentication data" | awk '{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) {if($i==535 && $j~/set_id=/) print $1,$2,$3,$(i-1),$j}}}' | grep -v "127.0.0.1\|localhost" | sed 's/(//g;s/)//g;s/[][]//g;s/set_id=//' | awk '{gsub(/:.*/,"",$4)}1' | awk '{printf "%-19s %-17s %-22s %-22s %-50s\n","DATE: "$1,"TIME: "$2,"TYPE: "$3,"IP: "$4,"EMAIL: "$NF}' | sort | uniq -c >>$temp/$type-unban_$time.txt
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
