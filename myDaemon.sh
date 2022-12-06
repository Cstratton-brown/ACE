#! /usr/bin/env bash

# This is a template for a daemon, commented as needed

DAEMONNAME="MY-DAEMON"

MYPID=$$
PIDDIR="."
PIDFILE="${PIDDIR}/${DAEMONNAME}.pid"

LOGDIR="."
LOGFILE="${LOGDIR}/${DAEMONNAME}.log"

LOGMAXSIZE=1024 # 1 Mb?

RUNINTERVAL=60	#60 SECONDS

doCommands()
{
	echo "Running Commands."
}
#####################################################
# Below is the template functionality of the Daemon #
#####################################################


setupDaemon()
{
	# Make sure that the directories exist/work/are not void
	if [[ ! -d "${PIDDIR}" ]]; then	# Checks if PIDDIR actually exists as a directory, if not creates it
		mkdir "${PIDDIR}"
	fi
	if [[ ! -d "${LOGDIR}" ]]; then	# Checks if LOGDIR exists as a directory, if not creates it
		mkdir "${LOGDIR}"
	fi
	if [[ ! -f "${LOGFILE}" ]]; then # Checks if LOGFILE exists as a file, if not creates it
		touch "${LOGFILE}"
	else
		SIZE=$(( $(stat --printf="%s" "${LOGFILE}") /1024)) # checks that logfile size is less than max size
		if [[ ${SIZE} -gt ${LOGMAXSIZE} ]]; then
			mv ${LOGFILE} ${LOGFILE}.$(date +%y%m%dT%H%M%S).old	# if not rename old logfile and create new one
		fi
	fi	
}

startDaemon()
{
   setupDaemon # Make sure that the files etc are there

   if ! checkDaemon; then
	   echo 1>&2 " * Error: ${DAEMONNAME} is already running." >> ${LOGFILE}
	   exit 1
   fi
   echo " * starting ${DAEMONNAME} with PID: ${MYPID}" >> ${LOGFILE}
   echo "${MYPID}"> ${PIDFILE}
   
   loop
}

stopDaemon()
{
if checkDaemon; then
	echo 1>&2 " * Error: ${DAEMONNAME} is not running." >> ${LOGFILE}
	exit 1
fi
echo " * stopping ${DAEMONNAME}" >> ${LOGFILE}
if [[ ! -z $(cat ${PIDFILE}) ]]; then
	kill -9 $(cat ${PIDFILE}) &> /dev/null
   	echo " * Stopped ${DAEMONNAME} with PID: ${MYPID}" >> ${LOGFILE}
else
   	echo " * Cannot find ${DAEMONNAME} with PID: ${MYPID}" >> ${LOGFILE}
fi
}
statusDaemon()
{
	if ! checkDaemon; then
		echo" * ${DAEMONNAME} is not running" >> ${LOGFILE}
		echo "Inactive"
	else 
		echo" * ${DAEMONNAME} is running" >> ${LOGFILE}
		echo "Active"
	fi
	exit 0
}
restartDaemon()
{
if ! checkDaemon; then
	echo" * ${DAEMONNAME} is not running" >> ${LOGFILE}
	exit 1
fi
stopDaemon
startDaemon
}
checkDaemon()
{
 # Check to see if Daemon is running
 # This is different from statusDaemon
 # an is called internally

 if [[ -z "${OLDPID}" ]]; then
	return 0
 elif ps -ef | grep "${OLDPID}" | grep -v grep | grep -v "0:00:00" | grep bash &> /dev/null ; then
       	# Daemon is running with wrong PID as in last called/saved
	restartDaemon
    return 1
 else
    return 0
 fi
}

loop()
{
  while true; do
   # Make sure stuff happens every 60 seconds
   NOW=$(date "+%s")
   if [[ -z ${LAST} ]]; then
	  LAST=${NOW}
   fi  
doCommands
LAST=$(date "+%s")
# set sleep interval
if [[ ! $((${NOW}-${LAST}+${RUNINTERVAL}+1)) -lt ${RUNINTERVAL} ]]; then
	sleep $((${NOW}-${LAST}+${RUNINTERVAL}))
fi
done
}

#########################################################################
# parse the commands							#
#########################################################################

if [[ -f "${OLDPID}" ]]; then
	OLDPID=$(cat "${PIDFILE}")
fi
checkDaemon

case "$1" in
	start)
	   startDaemon
		;;
	stop)
	   stopDaemon
		;;
	status)
	   statusDaemon
		;;
	restart)
	   restartDaemon
		;;
	*)
		echo 1>&2 "* Error: Usage $0 {start | stop | restart | status} "
		exit 1
esac

exit 0
# refactor, maths outside if statement

