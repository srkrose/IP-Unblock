#!/bin/bash

source /home/sample/scripts/dataset.sh

ip="124.6.243.64"

function ip_unblock() {
	search=$(csf -g $ip | tail -1 | grep -v "csf.allow\|No matches found")

	if [[ ! -z "$search" ]]; then
		type=$(echo "$search" | awk '{print $1}')

		if [[ "$type" == "csf.deny:" ]]; then
			reason=$(echo "$search" | awk '{print $6,$7}')
			dtime=$(echo "$search" | awk '{print $NF"-"$(NF-3)"-"$(NF-2)"_"$(NF-1)}')

			result=$(csf -dr $ip | grep "LOGDROPOUT")
		else
			history=$(whmapi1 get_cphulk_excessive_brutes | grep -A 2 "$ip" | awk '!seen[$0]++')

			reason=$(echo "$history" | grep "notes:" | awk '{print $4,$6}')
			dtime=$(echo "$history" | grep "logintime:" | awk '{print $2"_"$3}')

			result=$(whmapi1 flush_cphulk_login_history_for_ips ip=$ip | grep -i "result:" | awk '{print $2}')
		fi

		if [[ ! -z "$result" ]]; then
			action="UNBLOCKED"
		else
			action="UNBLOCK FAILED"
		fi

		content=$(echo "$ip: $dtime - $reason - $action")

		send_sms
	fi
}

function send_sms() {
	message=$(echo "$hostname: $content")

	#php $scripts/send_sms.php "$message" "$validation"

	curl -X POST -H "Content-type: application/json" --data "{\"text\":\"$message\"}" $statusslack
}

ip_unblock
