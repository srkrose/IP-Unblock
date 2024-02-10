#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /usr/local/cpanel/logs/cphulkd.log | grep "$ip" | awk -F'[= ]' '{for (i=0;i<NF;i++) {for (j=0;j<NF;j++) {for (k=0;k<NF;k++) {if ($i=="[Service]" && $j=="[Remote" && $(j+1)=="IP" && $k=="[Username]") print $1,$2,$(i+1),$(j+3),$(k+1)}}}}' | sed 's/[][]//g' | awk '{printf "%-19s %-17s %-21s %-22s %-50s\n","DATE: "$1,"TIME: "$2,"SERVICE: "$3,"IP: "$4,"USER: "$NF}' | sort | uniq -c >>$temp/$type-unban_$time.txt
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
