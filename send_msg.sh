#!/bin/bash
. ./env.list
echo "Sending Messgage"

MYDATE=$(date +"%b %d %H:%M:%S")
DATA="{\"mydata1\":\"myval1\", \"mydata2\":\"myval2\", \"mydata3\":\"myval3\"}"
MSG="<14>${MYDATE} MYHOST ${DATA}"
#echo "Sending $MSG"
echo "$MSG" | ncat -w 1 -u $(hostname) $APP_SYSLOG_UDP_PORT
