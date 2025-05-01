#!/bin/bash
######################################################################################
# check-notification-letter-producer-started.sh                                                    #
# Script to check JMS arrived on manages server and notificationletterproducer has started        #
# Alert On Call if string 'Start of NotificationLetterProducerMDB' is not in logs by certain time #
# If alerted, possible Admin server failure to send MDB to managed server wlserver1   #
######################################################################################

######################################################################################
# TODO --- to be updated with DEEP-299 implement JMS queue consumer?

#cd /apps/oracle/notification-letter-producer
#
# load variables created from setCron script - being careful not to overwrite HOME as msmtp mail process uses it to find config
#KEEP_HOME=${HOME}
#source /apps/oracle/env.variables
#HOME=${KEEP_HOME}

######################################################################################

source alert_functions

# set up logging
LOGS_DIR=../logs/notification-letter-producer
mkdir -p ${LOGS_DIR}
LOG_FILE="${LOGS_DIR}/${HOSTNAME}-check-notification-letter-producer-started.log"
source logging_functions

exec > >(tee "${LOG_FILE}") 2>&1

f_logInfo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
f_logInfo "Starting check-notification-letter-producer-started"

WLS_LOG="/apps/oracle/logs/wlserver1/logs/wlserver1.out"
RESULT=$(grep 'Start of NotificationLetterProducerMDB' ${WLS_LOG})

if [[ -n $RESULT ]];then
  ## All good, JMS message received for today
  f_logInfo " NotificationLetterProducerMDB received : $RESULT"
  exit 0
else
  ## MDB not received which means Letters are not processing
  f_logError "NotificationLetterProducerMDB NOT received. Probable error with Admin server or Managed Server !!!"
  email_CHAPS_group_f "NotificationLetterProducerMDB has not started in process-compliance" "NotificationLetterProducerMDB NOT received which means Letters are not processing. Check process_compliance log and ${WLS_LOG}."
  patrol_log_alert_chaps_f " `pwd`/`basename $0`: NotificationLetterProducerMDB has not started in process-compliance which means Letters are not processing. "
  exit 1
fi