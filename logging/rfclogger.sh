#! /usr/bin/env bash
# Fail on first error
set -e
#--------------------------------------------------------------------------------------------------
# Configurables

# RFC-5424 log levels
# -------------------
# DEBUG: Detailed debug information.
# INFO: Interesting events
# NOTICE: Normal but significant events.
# WARNING: Exceptional occurrences that are not errors
# ERROR: Runtime errors that do not require immediate action but
#        should typically be logged and monitored.
# CRITICAL: Critical conditions.
# ALERT: Action must be taken immediately.
# EMERGENCY: Emergency: System is unusable.
#
# An additional level OFF is added.
# When log level set to OFF no more messages are logged to the console

declare -A LOG_LEVELS
export LOG_LEVELS=([OFF]=8 [DEBUG]=7 [INFO]=6 [NOTICE]=5 [WARNING]=4 [ERROR]=3 [CRITICAL]=2 [ALERT]=1 [EMERGENCY]=0)
# Make sure that HOME exist
export HOME=${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}

# Default formats
export DEF_LOG_FORMAT='%DATE %PID [%LEVEL] %MESSAGE'
# ISO 8601
export DEF_LOG_DATE_FORMAT='+%F %T %Z'
# Define LOG variables
LOG_VARS() {
    export LOG_LOGFILE_ENABLE=${LOG_LOGFILE_ENABLE:-1}  # Enable logging to file
    export LOGFILE=${LOGFILE:-"$HOME/tmp/bash-logger/my-bash-logger.log"}
    export LOG_FORMAT=${LOG_FORMAT:-$DEF_LOG_FORMAT}
    export LOG_DATE_FORMAT=${LOG_DATE_FORMAT:-$DEF_LOG_DATE_FORMAT} #Eg:2014-09-07 21:51:57
    export LOG_COLOR_ENABLE=${LOG_COLOR_ENABLE:-1}  # Enable colors by default
    export LOG_LEVEL=${LOG_LEVEL:-${LOG_LEVELS[DEBUG]}} # Logs all messages to the terminal
    export LOG_COLOR_DEBUG=${LOG_COLOR_DEBUG:-"\033[0;34m"} # Blue
    export LOG_COLOR_INFO=${LOG_COLOR_INFO:-"\033[0;37m"}  # White
    export LOG_COLOR_NOTICE=${LOG_COLOR_NOTICE:-"\033[1;32m"} # Green
    export LOG_COLOR_WARNING=${LOG_COLOR_WARNING:-"\033[1;33m"} # Yellow
    export LOG_COLOR_ERROR=${LOG_COLOR_ERROR:-"\033[1;31m"}  # Red
    export LOG_COLOR_CRITICAL=${LOG_COLOR_CRITICAL:-"\033[44m"} # Blue Background
    export LOG_COLOR_ALERT=${LOG_COLOR_ALERT:-"\033[45m"} # Purple Background
    export LOG_COLOR_EMERGENCY=${LOG_COLOR_EMERGENCY:-"\033[41m"} # Red Background
    export RESET_COLOR=${RESET_COLOR:-"\033[0m"}
}

# Set LOG variables
LOG_VARS
#----------------------------------------------------------------------------------------
# Individual Log Functions
# These can be overwritten to provide custom behavior for different log levels

OFF()       { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
DEBUG()     { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
INFO()      { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
NOTICE()    { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
WARNING()   { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
ERROR()     { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; exit 1; }
CRITICAL()  { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; exit 1; }
ALERT()     { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; exit 1; }
EMERGENCY() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; exit 1; }
#-------------------------------------------------------------------------------------------
# Helper Functions

# Outputs a log formatted using the LOG_FORMAT and DATE_FORMAT configurables
# Usage: FORMAT_LOG <log level> <log message>
# Eg: FORMAT_LOG CRITICAL "My critical log"
FORMAT_LOG() {
    local level="$1"
    local log="$2"
    local pid=$$
    local date="$(date "$LOG_DATE_FORMAT")"
    local formatted_log="$LOG_FORMAT"
    formatted_log="${formatted_log/'%MESSAGE'/$log}"
    formatted_log="${formatted_log/'%LEVEL'/$level}"
    formatted_log="${formatted_log/'%PID'/$pid}"
    formatted_log="${formatted_log/'%DATE'/$date}" 
    echo "$formatted_log"
}
# Calls one of the individual log functions
# Usage: LOG <log level> <log message>
# Eg: LOG INFO "My info log"
LOG() {
    local level="$1"
    local log="$2"
    local log_function_name="${level^^}"
    $log_function_name "$log"
}
# Get the level value from level name
# Eg: LOG_LEVEL_VALUE <DEBUG | INFO | ...>
LOG_LEVEL_VALUE() {
    local level="${1}"
    [ -z "${LOG_LEVELS[$level]+isset}" ] && return 1
    echo "${LOG_LEVELS[$level]}"
}
# Get log level name from numeric value.
# Eg: LOG_LEVEL_NAME <0..7>
LOG_LEVEL_NAME() {
    local level=""
    local value="${1}"
    for level in "${!LOG_LEVELS[@]}"; do
       [ "${LOG_LEVELS[$level]}" -eq "${value}" ] && echo "${level}" && return 0
    done
    return 1
}
#------------------------------------------------------------------------------------------
# Log Handlers

# All log levels call this handler (by default...)
# logging behavior
# Usage: LOG_HANDLER_DEFAULT <log level> <log message>
# Eg: LOG_HANDLER_DEFAULT DEBUG "My debug log"
LOG_HANDLER_DEFAULT() {
    # From pipe
    if [ -p /dev/stdin ]; then
        local level="$1"
        shift
        while read -r line; do
            args=()
            if [ -n "$*" ]; then
                args+=( "$@" )
            fi
            args+=( "${line}" );
            LOG_HANDLER_OUT "$level" "${args[*]}"
        done
    # Normal log
    else
        LOG_HANDLER_OUT "$@"
    fi
}
# Used by LOG_HANDLER_DEFAULT to output the log
LOG_HANDLER_OUT(){
    local level="$1"
    local formatted_log="$(FORMAT_LOG "$@")"
    if [ "${LOG_COLOR_ENABLE}" -eq "1" ]; then
            LOG_HANDLER_COLORTERM "$level" "$formatted_log"
    else
            LOG_HANDLER_TERM "$level" "$formatted_log"
    fi

    if [ "${LOG_LOGFILE_ENABLE}" -eq "1" ]; then
        LOG_HANDLER_LOGFILE "$level" "$formatted_log"
    fi
}
# Outputs a log to the stdout, colourised using the LOG_COLOR configurables
# Usage: LOG_HANDLER_COLORTERM <log level> <log message>
# Eg: LOG_HANDLER_COLORTERM CRITICAL "My critical log"
LOG_HANDLER_COLORTERM() {
    local level="$1"
    local level_value="$(LOG_LEVEL_VALUE "$level")"
    local log="$2"
    local color_variable="LOG_COLOR_$level"
    local color="${!color_variable}"
    log="$color$log$RESET_COLOR"

    [ "${LOG_LEVEL}" -eq "${LOG_LEVELS[OFF]}" ] && return 0
    [ "${level_value}" -gt "$LOG_LEVEL" ] && return 0
    echo -e "$log"
}
# Outputs a log to the stdout, without color
# Usage: LOG_HANDLER_TERM <log level> <log message>
# Eg: LOG_HANDLER_TERM CRITICAL "My critical log"
LOG_HANDLER_TERM() {
    local level="$1"
    local level_value="$(LOG_LEVEL_VALUE "$level")"
    local log="$2"

    [ "${LOG_LEVEL}" -eq "${LOG_LEVELS[OFF]}" ] && return 0
    [ "${level_value}" -gt "$LOG_LEVEL" ] && return 0
    echo -e "$log"
}
# Appends a log to the configured logfile
# Usage: LOG_HANDLER_LOGFILE <log level> <log message>
# Eg: LOG_HANDLER_LOGFILE NOTICE "My critical log"
LOG_HANDLER_LOGFILE() {
    local level="$1"
    local log="$2"
    local log_path="$(dirname "$LOGFILE")"
    [ -d "$log_path" ] || mkdir -p "$log_path"
    echo "$log" >> "$LOGFILE"
    LOG_ROTATION
}
# Rotates logs if current log is over 500 lines
LOG_ROTATION(){
    local log_size=$(wc -l $LOGFILE | awk '{print $1}')
    local count_log_files=$(ls ${LOGFILE%/*} | grep "${LOGFILE##/*}.*.gz" | wc -l )
    if [[ ${log_size} -gt 500 ]]; then
        if [ ${count_log_files} -gt 0 ]; then
            for ((i=${count_log_files}; i!=0; i--)); do
                    local n=$((${i}+1))
                    mv ${LOGFILE}.${i}.gz ${LOGFILE}.${n}.gz
            done
        fi
        gzip -c "${LOGFILE}" > "${LOGFILE}.1.gz"
        echo "" > ${LOGFILE}
   fi
}
# Reset log variables to default values
LOG_RESET() {
    unset LOGFILE
    unset LOG_FORMAT
    unset LOG_DATE_FORMAT
    unset LOG_COLOR_ENABLE
    unset LOG_LEVEL
    unset LOG_COLOR_DEBUG
    unset LOG_COLOR_INFO
    unset LOG_COLOR_NOTICE
    unset LOG_COLOR_WARNING
    unset LOG_COLOR_ERROR
    unset LOG_COLOR_CRITICAL
    unset LOG_COLOR_ALERT
    unset LOG_COLOR_EMERGENCY
    unset RESET_COLOR

    LOG_VARS
}

