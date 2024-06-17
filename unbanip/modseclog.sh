#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	cat /var/log/apache2/error_log | grep "$ip" | grep "ModSecurity:" | grep "Access denied with code" | awk '{id=""; hostname=""; msg=""; for(i=1;i<=NF;i++) {if($i=="[msg") {msg_start=index($0,"[msg"); msg=substr($0,msg_start+5); msg_end=index(msg,"]"); msg=substr(msg,1,msg_end-1);} if($i=="[id") {id=$(i+1);} if($i=="[hostname") {hostname=$(i+1);} {gsub(/\..*/, "", $4);}} printf "%-20s %-17s %-22s %-14s %-30s %-30s\n","DATE: "$5"-"$2"-"$3,"TIME: "$4,"IP: "$8,"ID: "id,"HOST: "hostname,"MSG: "msg;}' | sed 's/[][]//g;s/"//g' | uniq -c >>$temp/$type-unban_$time.txt
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
