#!/bin/bash

d0=$0 # Record script name as it is lost when calling functions

######################################################################################
# TODO --- to be updated with DEEP-299 implement JMS queue consumer?

# cd /apps/oracle/notification-letter-producer

# load variables created from setCron script - being careful not to overwrite HOME as msmtp mail process uses it to find config
#KEEP_HOME=${HOME}
#source /apps/oracle/env.variables
#HOME=${KEEP_HOME}

######################################################################################

#CLASSPATH=$CLASSPATH:.:/apps/oracle/libs/wlfullclient.jar:/apps/oracle/libs/log4j-1.2-api.jar:/apps/oracle/libs/log4j-api.jar:/apps/oracle/libs/log4j-core.jar:/apps/oracle/letter-producer/letter-producer.jar
#TODO-- update above line when CLASSPATH and env.variables are provided

# set up logging
LOGS_DIR=../logs/notification-letter-producer
mkdir -p ${LOGS_DIR}
LOG_FILE="${LOGS_DIR}/${HOSTNAME}-notification-letter-producer-$(date +'%Y-%m-%d_%H-%M-%S').log"
source logging_functions
source alert_functions

function main_f {

exec > >(tee "${LOG_FILE}") 2>&1
  f_logInfo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  f_logInfo "Starting notification-letter-producer"
  f_logInfo "start notification-letter-producer: %s\n" "$(date)"

  ## set up Global Env Standalone specific variables like PATH, global CLASSPATH, connections, alerts across jobs, etc.
  if [[ -e $HOME/notification-letter-producer/notification-letter-producer.properties ]]; then
    . $HOME/notification-letter-producer/notification-letter-producer.properties
  fi

##- access denied due to JMS variables not set. TODO-- comment to be removed when deep-299 implementation complete.
f_logInfo "Checking that notification-letter-producer is not already running"
../scripts/check-for-jms-message.sh ${JMS_LETTERPRODUCERQUEUE}
if [ $? -gt 0 ]; then
        f_logError "notification-letter-producer may be already running or connection error.  Please investigate."
        patrol_log_alert_chaps_f " `pwd`/`basename $0`:  notification-letter-producer may be already running or connection error.  Please investigate."
        exit 1
fi

#/usr/java/jdk-8/bin/java -Din=letter-producer -cp $CLASSPATH -Dlog4j.configuration=log4j.xml uk.gov.companieshouse.notificationletterproducer.NotificationLetterProducerRunner notification-letter-producer.properties
#TODO-- update above line when CLASSPATH and env.variables are provided
  if [ $? -gt 0 ]; then
    f_logError "Non-zero exit code for notification-letter-producer java execution\n"
      f_logInfo "ending notification-letter-producer: %s\n" "$(date)"
    exit 1
  fi
   f_logInfo "Ending letter-producer"
   f_logInfo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

}

cd ${0%/*} # cd into directory to run
main_f "$@" || {
  printf "$d0:ERROR: main_f failed\n" >&2
  return 1
}
