#!/bin/bash
source ./images-list.sh

CONTAINER_NAME="spring-petclinic-angular"
IMAGE_NAME="${IMAGES[$CONTAINER_NAME]}"

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 port api_hostname api_port" >&2
    exit 1
fi

port=$1
api_hostname=$2
api_port=$3

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker run -d --add-host=host.docker.internal:host-gateway \
        --name "$CONTAINER_NAME" \
        -p $port:8080 \
        -e REST_API_HOSTNAME=$api_hostname \
        -e REST_API_PORT=$api_port \
        "$IMAGE_NAME" >/dev/null \
    && echo "Started container $CONTAINER_NAME using port $port" \
    || { echo "Error starting container $CONTAINER_NAME using port $port"; exit 1; }
