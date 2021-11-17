#!/bin/bash
CONTAINER_NAME="mysql-petclinic-slave"

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 port master_hostname master_port" >&2
    exit 1
fi

port=$1
master_hostname=$2
master_port=$3

source ./mysql.sh

master_data=$(echo "SHOW MASTER STATUS \G" | docker exec -i "$CONTAINER_NAME" sh -c "exec mysql -u\"$MYSQL_USER\" -p\"$MYSQL_PASSWORD\" -h\"$master_hostname\" -P$master_port \"\$MYSQL_DATABASE\"")
if [[ $? ]]
then
    echo "Master details: $master_data"
else
    echo "Error getting master data from $master_hostname:$master_port"
    exit 2
fi
master_file=$(echo "$master_data" | grep File | sed 's/^.*File: \([a-z0-9.-]\+\).*$/\1/igm')
master_position=$(echo "$master_data" | grep Position | sed 's/^.*Position: \([0-9]\+\).*$/\1/igm')
echo "CHANGE MASTER TO MASTER_HOST='$master_hostname', MASTER_PORT=$master_port, MASTER_USER='root', MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD', MASTER_LOG_FILE='$master_file', MASTER_LOG_POS=$master_position; START SLAVE;" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'

echo "Done."
