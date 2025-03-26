#!/bin/bash

d0=$0 # Record script name as it is lost when calling functions

function main_f {
  printf "start notification-letter-producer: %s\n" "$(date)"

  ## set up Global Env Standalone specific variables like PATH, global CLASSPATH, connections, alerts across jobs, etc.
  if [[ -e $HOME/standalone/standalone.properties ]]; then
    . $HOME/standalone/standalone.properties
  fi

  java -jar notification-letter-producer.jar notification-letter-producer.properties

  if [ $? -gt 0 ]; then
    printf "Non-zero exit code for notification-letter-producer java execution\n"
    exit 1
  fi

  printf "ending notification-letter-producer: %s\n" "$(date)"
}

cd ${0%/*} # cd into directory to run
main_f "$@" || {
  printf "$d0:ERROR: main_f failed\n" >&2
  return 1
}
