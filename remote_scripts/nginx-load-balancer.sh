#!/bin/bash
source ./images-list.sh

CONTAINER_NAME="nginx-load-balancer"
IMAGE_NAME="${IMAGES[$CONTAINER_NAME]}"

if [[ "$#" -ne 5 ]]
then
    echo "Usage: $0 port readapi_hostname readapi_port writeapi_hostname writeapi_port" >&2
    exit 1
fi

port=$1
proxy_get_hostname=$2
proxy_get_port=$3
proxy_other_hostname=$4
proxy_other_port=$5

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker run --rm -d --add-host=host.docker.internal:host-gateway \
        --name "$CONTAINER_NAME" \
        -p $port:80 \
        -e REST_API_READ_HOSTNAME=$proxy_get_hostname \
        -e REST_API_READ_PORT=$proxy_get_port \
        -e REST_API_WRITE_HOSTNAME=$proxy_other_hostname \
        -e REST_API_WRITE_PORT=$proxy_other_port \
        "$IMAGE_NAME" >/dev/null \
    && echo "Started container $CONTAINER_NAME using port $port" \
    || { echo "Error starting container $CONTAINER_NAME using port $port"; exit 1; }
