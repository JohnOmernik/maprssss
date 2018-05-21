#!/bin/bash


. ./env.list

PORTS="-p ${APP_SYSLOG_UDP_PORT}:${APP_SYSLOG_UDP_PORT}/udp -p ${APP_SYSLOG_TCP_PORT}:${APP_SYSLOG_TCP_PORT}/tcp -p ${APP_STREAMSETS_TCP_PORT}:${APP_STREAMSETS_TCP_PORT}/tcp"

if [ "$MAPR_TICKETFILE_LOCATION" != "" ]; then
    echo "Setting Secure Cluster"
    VOLS="-v=${MAPR_TICKET_HOST_LOCATION}:${MAPR_TICKET_CONTAINER_LOCATION}:ro"
else
    VOLS=""
fi

if [ "$1" == "1" ]; then
    CMD="/bin/bash"
else
    CMD="/opt/streamsets/init.sh"
fi

env|sort|grep -P "^(MAPR_|APP_)" > ./env.list.docker

sudo docker run -it $PORTS $VOLS --env-file ./env.list.docker \
--device /dev/fuse \
--ipc host \
--cap-add SYS_ADMIN \
--cap-add SYS_RESOURCE \
--security-opt apparmor:unconfined \
 $APP_IMG $CMD
