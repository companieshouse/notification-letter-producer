@echo off

if [%1]==[] goto :usage

:run
	set PROPERTIES=%1
	java -jar notification-letter-producer.jar %PROPERTIES%
	exit /B 0

:usage
    echo "Usage: %0 <PROPERTIES_FILE>"
    exit /B 1
