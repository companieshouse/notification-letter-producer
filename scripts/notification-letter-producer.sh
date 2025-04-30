#!/bin/bash

d0=$0 # Record script name as it is lost when calling functions

# set up logging
LOGS_DIR=../logs/notification-letter-producer
mkdir -p ${LOGS_DIR}
LOG_FILE="${LOGS_DIR}/${HOSTNAME}-notification-letter-producer-$(date +'%Y-%m-%d_%H-%M-%S').log"
source logging_functions

function main_f {

exec > >(tee "${LOG_FILE}") 2>&1
  f_logInfo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  f_logInfo "Starting notification-letter-producer"
  f_logInfo "start notification-letter-producer: %s\n" "$(date)"

  ## set up Global Env Standalone specific variables like PATH, global CLASSPATH, connections, alerts across jobs, etc.
  if [[ -e $HOME/standalone/standalone.properties ]]; then
    . $HOME/standalone/standalone.properties
  fi

f_logInfo "Checking that notification-letter-producer is not already running"
../scripts/check-for-jms-message.sh ${JMS_LETTERPRODUCERQUEUE}
if [ $? -gt 0 ]; then
        f_logError "notification-letter-producer may be already running or connection error.  Please investigate."
        patrol_log_alert_chaps_f " `pwd`/`basename $0`:  notification-letter-producer may be already running or connection error.  Please investigate."
        exit 1
fi

  if [ $? -gt 0 ]; then
    f_logError "Non-zero exit code for notification-letter-producer java execution\n"
      f_logInfo "ending notification-letter-producer: %s\n" "$(date)"
          f_logInfo "Ending letter-producer"
          f_logInfo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    exit 1
  fi

}

cd ${0%/*} # cd into directory to run
main_f "$@" || {
  printf "$d0:ERROR: main_f failed\n" >&2
  return 1
}
