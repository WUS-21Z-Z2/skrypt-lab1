#!/bin/bash
source ./images-list.sh

for key in "${!IMAGES[@]}"
do
    docker stop "$key" 2>/dev/null
    docker rmi -f "${IMAGES[$key]}" 2>/dev/null
done

exit 0
