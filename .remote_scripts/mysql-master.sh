#!/bin/bash
CONTAINER_NAME="mysql-petclinic-master"

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 port" >&2
    exit 1
fi

port=$1

source ./mysql.sh

echo "Done."
