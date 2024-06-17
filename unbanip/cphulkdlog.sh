#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /usr/local/cpanel/logs/cphulkd.log | grep "$ip" | awk -F'[= ]' '{service=""; ip=""; user=""; for (i=1;i<=NF;i++) {if($i=="[Service]") {service=$(i+1);} if($i=="[Remote" && $(i+1)=="IP") {ip=$(i+3);} if($i=="[Username]") {user=$(i+1);}} printf "%-19s %-17s %-21s %-22s %-50s\n","DATE: "$1,"TIME: "$2,"SERVICE: "service,"IP: "ip,"USER: "user;}' | sed 's/[][]//g' | uniq -c >>$temp/$type-unban_$time.txt
}

function filter_log() {
	if [ -r $temp/$type-unban_$time.txt ] && [ -s $temp/$type-unban_$time.txt ]; then
		today=$(date +"%F")
		yesterday=$(date -d 'yesterday' +"%F")

		data=$(cat $temp/$type-unban_$time.txt | grep "$today")

		if [[ -z "$data" ]]; then
			data=$(cat $temp/$type-unban_$time.txt | grep "$yesterday")

			if [[ ! -z "$data" ]]; then
				echo "$data" >>$svrlogs/unbanip/cphulk/$type-unban_$time.txt

			else
				echo "$type: $ip - No log records found" >>$svrlogs/unbanip/cphulk/$type-unban_$time.txt
			fi

		else
			echo "$data" >>$svrlogs/unbanip/cphulk/$type-unban_$time.txt
		fi
		
		cat $svrlogs/unbanip/cphulk/$type-unban_$time.txt
	fi
}

log_data

filter_log
