#!/bin/bash
source ./images-list.sh

IMAGE_NAME="${IMAGES[$CONTAINER_NAME]}"

if [[ "$#" -ne 3 ]] && [[ "$#" -ne 5 ]]
then
    echo "Usage: $0 port masterdb_hostname masterdb_port [slavedb_hostname slavedb_port]" >&2
    exit 1
fi

port=$1
masterdb_hostname=$2
masterdb_port=$3
slavedb_hostname=$4
slavedb_port=$5

if [[ "$#" -eq 3 ]]
then
    datasource_url="jdbc:mysql://$masterdb_hostname:$masterdb_port/petclinic?useUnicode=true"
else
    datasource_url="jdbc:mysql:replication://$masterdb_hostname:$masterdb_port,$slavedb_hostname:$slavedb_port/petclinic?useUnicode=true"
fi

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker run -d --add-host=host.docker.internal:host-gateway \
        --name "$CONTAINER_NAME" \
        -p $port:9966 \
        "$IMAGE_NAME" "--spring.datasource.url=$datasource_url" >/dev/null \
    && echo "Started container $CONTAINER_NAME using port $port" \
    || { echo "Error starting container $CONTAINER_NAME using port $port"; exit 1; }
