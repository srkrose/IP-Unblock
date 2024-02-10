#!/bin/bash

source /home/sample/scripts/dataset.sh

ip=$1
type=$2

function log_data() {
	mua=$(echo "$type" | cut -c 1-4)

	cat /var/log/maillog | grep "$ip" | grep -ie "dovecot:" | grep -ie "$mua-login:" | grep -ie "auth failed" | grep -iv "Inactivity\|user=<>" | awk '{for(i=1;i<=NF;i++) {for(j=1;j<=NF;j++) {if($i~/user=/ && $j~/rip=/) {print $1,$2,$3,$6,$j,$i}}}}' | sed 's/dovecot//;s/user//;s/rip//;s/=//g;s/,//g;s/<//;s/>//' | awk '{gsub(/:/,"",$4)}1' | awk '{printf "%-15s %-17s %-19s %-22s %-50s\n","DATE: "$1" "$2,"TIME: "$3, "TYPE: "$4,"IP: "$5,"USER: "$NF}' | sort | uniq -c >>$temp/$type-unban_$time.txt
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
