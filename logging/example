#!/usr/bin/env bash

# Including the logger functions
source rfclogger.sh

# set log level do DEBUG
LOG_LEVEL=$(LOG_LEVEL_VALUE DEBUG)
INFO "Log level set to $(LOG_LEVEL_NAME ${LOG_LEVEL})"

# Regular Usage
echo # newline
DEBUG "Debug log with default configurations"
INFO "Info log with default configurations"
NOTICE "Notice log with default configurations"
WARNING "Waring log with default configurations"

# Overwriting default configurables
echo # newline
export LOGFILE=~/my-bash-logger.log
export LOG_DATE_FORMAT='+%c'
export LOG_FORMAT='%LEVEL %DATE -- %MESSAGE'
WARNING "Configurations changed"
DEBUG "example debug log"
INFO "example info log"
NOTICE "example notice log"
WARNING "example warning log"

# reset to overwrite config changes
echo # newline
LOG_RESET
export LOGFILE=./my-bash-logger.log
WARNING "Configurations Reset"
DEBUG "example debug log"
INFO "example info log"
NOTICE "example notice log"
WARNING "example warning log"


# Overwriting log function behavior (eg. don't exit on errors)
echo # newline
INFO "Changing default log behavior"
ERROR()     { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
CRITICAL()  { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
ALERT()     { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
EMERGENCY() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
NOTICE "default logging behavior overwritten"

# Example of all log levels
echo # newline
DEBUG "Example Debug log"
INFO "Example Info log"
NOTICE "Example Notice log"
WARNING "Example Warning log"
ERROR "Example Error log"
CRITICAL "Example Critical log"
ALERT "Example Alert log"
EMERGENCY "Example Emergency log"

# Overwriting default log behavior (eg. adding another echo)
echo # newline
INFO "Adding additional default behavior"
LOG_HANDLER_DEFAULT() {
    local formatted_log="$(FORMAT_LOG "$@")"
    LOG_HANDLER_COLORTERM "$1" "$formatted_log"
    LOG_HANDLER_LOGFILE "$1" "$formatted_log"
    echo "logged to logfile"
}
NOTICE "test notice log"

# From pipe
source rfclogger.sh
echo # newline
echo "Log message from pipe" | NOTICE
echo "Log message from pipe" | WARNING "prefix:"
# Pipe multiline input
echo -e "This is a\nmultiline message\nfrom pipe" | NOTICE "pipe:"
# Pipe empty message
echo "" | WARNING "pipe:"

# Do not log to file
export LOG_LOGFILE_ENABLE=0
WARNING "NOT LOGGING TO FILE"
DEBUG "NOT LOGGING TO FILE"
INFO "NOT LOGGING TO FILE"
NOTICE "NOT LOGGING TO FILE"
