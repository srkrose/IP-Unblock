#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/exim_mainlog | grep "$ip" | grep "dropped: too many syntax or protocol errors" | grep "RCPT TO:" | grep -v "127.0.0.1\|localhost" | awk '{ip=""; email=""; for(i=1;i<=NF;i++) {if($i=="dropped:") {ip=$(i-1); gsub(/:.*/, "", ip); gsub(/\[|\]/, "", ip);} if($i~/RCPT/ && $(i+1)=="TO:") { match($0, /"RCPT TO: <[^">]*>/); email=substr($0, RSTART+11, RLENGTH-12); gsub(/'\''/, "", email); gsub(/^ */, "", email);}} printf "%-19s %-17s %-13s %-22s %-50s\n","DATE: "$1,"TIME: "$2,"TYPE: "$3,"IP: "ip,"EMAIL: "email;}' | uniq -c >>$temp/$type-unban_$time.txt
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
