#!/bin/bash

cpuser="sample"
scripts="/home/$cpuser/scripts"
svrlogs="/home/$cpuser/svrlogs"
temp="$svrlogs/temp"
hostname=$(hostname | awk -F'.' '{print $1}')
svrdomain=$(hostname)
svrip=$(dig $(hostname) A +short)
logtime=$(date +"%Y-%m")
logdate=$(date +"%Y-%m-%d")
time=$(date +"%F_%T")
date=$(date +"%F")
svrport="XX"
sshkey="/ssh/key/path"
