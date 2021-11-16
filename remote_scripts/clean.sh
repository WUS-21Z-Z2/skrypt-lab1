#!/bin/bash
source ./images-list.sh

for key in "${!IMAGES[@]}"
do
    docker rm -f "$key" 2>/dev/null
    docker rmi -f "${IMAGES[$key]}" 2>/dev/null
done

exit 0
