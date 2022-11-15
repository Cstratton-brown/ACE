#! /usr/bin/env bash

# author: Charles Stratton-Brown
# Date Created: 25/10/2022
# Version 0.0.1
# Notes: if any

# Display help message 
USAGE(){
	echo -e $1
	echo -e "\nUseage: systemStats [-t temperature] [-F core-frequency] [-c cores] [-V volts]"
	echo -e "\t\t    [-m arm memory] [-M GPU memory] [-f free memory] [-i ipv4 and ipv6 address]"
	echo -e "\t\t    [-D Directory Space][-d Disk Space][-v version] [-h help]"
	echo -e "\t\t     more information see: man systemstats"
}

# Check for arguments (error checking)
ARGSLENGTH=$#
if [ $# -lt 1 ];then
	USAGE "Not enough arguments"
	exit 1
elif [[  ( $# -gt 1) || ( ${#1} -gt 10 )  ]];then
	USAGE "To many arguements"
	exit 1
elif [[ ( $1 == '--help' ) || ( $1 == '-h' ) ]];then
	USAGE "Help"
	exit 0
fi

# Frequently a script is written so that arguments can be passed in any order using 'flags'
# with flags method, some of the arguments can have optional commands!
# 'a:b' means that 'a' is expecting a mandatory command after it and 'b' is not, 'abc' means they all are mandatory commands

while getopts "tfFcVmMfivhdD" OPTION
do
case ${OPTION}
in
# 
t) TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{print substr ($0,1,2) "." substr ($0,3)}')
   echo "Temperature: ${TEMP}";;
m) ARM=$(vcgencmd get_mem arm | awk -F '=' '{print$2}')
   echo "arm memory: ${ARM}";;
M) GPU=$(vcgencmd get_mem gpu | awk -F '=' '{print$2}')
   echo "gpu memory: ${GPU}";;
f) FREE=$(free -m)
   echo -e "free memory: \n ${FREE}";;
F) CPU=$(grep -w 'cpu' /proc/stat | awk '{usage=($2+$3+$4+$6+$7+$8)*100/($2+$3+$4+$5+$6+$7+$8)} {free=($5)*100/($2+$3+$4+$5+$6+$7+$8)} END {printf  "\nUsed CPU: %.2f%%\n", usage} {printf "Free CPU: %.2f%%",free}')
   echo "${CPU}";;
i) IP=$(ifconfig wlan0 | grep -w -m1 inet | awk '{print$2}')
   echo "IP: ${IP}";;
c) CORES=$(cat /sys/devices/system/cpu/present)
   echo "CPU cores: ${CORES}";;
V) VOLTS=$(vcgencmd measure_volts| awk -F '=' '{print$2}')
   echo "Voltage: ${VOLTS}";;
d) DISK=$(df -h | grep root | awk '{print "Total Space Available:"  $2 " " "Space Used:" $3 " " "Space Available:" $4 " " "Percent Used:" $5}')
   echo -e "Disk Space:\n  ${DISK}";;
D) DIRECTORY=$(du -s --si ~/ACE)
   echo -e "Directory Space Size: ${DIRECTORY}";;
*) USAGE "\n${*} argument was not recognized";;
esac
done
