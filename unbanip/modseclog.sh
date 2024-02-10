#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/apache2/error_log | grep "$ip" | grep "ModSecurity:" | grep "Access denied with code" | awk '{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) {for(k=1;k<=NF;k++) {if($i=="[id" && $j=="[msg" && $k=="[hostname") print $2,$3,$4,$5,$8,$(i+1),$(j+2),$(k+1)}}}}' | sed 's/[][]//g;s/"//g' | awk '{gsub(/\.[0-9]+$/,"",$3)}1' | awk '{if($7=="dropped") $7 = "Bot"; printf "%-20s %-17s %-22s %-14s %-15s %-50s\n","DATE: "$4"-"$1"-"$2,"TIME: "$3,"IP: "$5,"ID: "$6,"MSG: "$7,"HOST: "$NF}' | sort | uniq -c >>$temp/$type-unban_$time.txt
}

function filter_log() {
	if [ -r $temp/$type-unban_$time.txt ] && [ -s $temp/$type-unban_$time.txt ]; then
		today=$(date +"%Y-%b-%d")
		yesterday=$(date -d 'yesterday' +"%Y-%b-%d")

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
