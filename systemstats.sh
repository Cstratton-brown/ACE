#! /usr/bin/env bash

# author: Charles Stratton-Brown
# Date Created: 25/10/2022
# Version 0.0.1
# Notes: if any

# Display help message 
USEAGE(){
	echo -e $1
	echo -e "\nUseage: systemStats [-t temperature] [-f core-frequency] [-c cores] [-V volts]"
	echo -e "\t\t    [-m arm memory] [-M GPU memory] [-f free memory] [-i ipv4 and ipv6 address]"
	echo -e "\t\t    [-v version] [-h help]"
	echo -e "\t\t     more information see man systemstats"
}

# Check for arguments (error checking)

if [ $# -lt 1 ];then
	USAGE "Not enough arguments"
	exit 1
elif [ $# -gt 10 ];then
	USAGE "To many arguements"
	exit 1
elif [[ ( $1 == '--help' ) || ( $1 == '-h' ) ]];then
	USAGE "Help"
	exit 0
fi

# Frequently a script is written so that arguments can be passed in any order using 'flags'
# with flags method, some of the arguments can have optional commands!
# 'a:b' means that 'a' is expecting a mandatory command after it and 'b' is not, 'abc' means they all are mandatory commands

while getopts "tfcVmMfivh" OPTION
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
i) IP=$(ifconfig wlan0 | grep -w -m1 inet | awk '{print$2}')
   echo "IP: ${IP}";;
c) CORES=$(cat /sys/devices/system/cpu/present)
   echo "CPU cores: ${CORES}";;
V) VOLTS=$(vcgencmd measure_volts| awk -F '=' '{print$2}')
   echo "Voltage: ${VOLTS}";;
*) USAGE "\n${*} argument was not recognized";;
esac
done
