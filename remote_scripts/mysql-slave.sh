#!/bin/bash
source ./images-list.sh
source ./db-init-checker.sh

CONTAINER_NAME="mysql-petclinic-slave"
IMAGE_NAME="${IMAGES[$CONTAINER_NAME]}"

MYSQL_ROOT_PASSWORD="petclinic"
MYSQL_USER="pc"
MYSQL_PASSWORD="petclinic"
MYSQL_DATABASE="petclinic"

DB_SCHEMA_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql"
DB_DATA_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql"

if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 port master_hostname master_port" >&2
    exit 1
fi

port=$1
master_hostname=$2
master_port=$3

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker run --rm -d --add-host=host.docker.internal:host-gateway \
        --name "$CONTAINER_NAME" \
        -p $port:3306 \
        -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
        -e MYSQL_USER="$MYSQL_USER" \
        -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
        -e MYSQL_DATABASE="$MYSQL_DATABASE" \
        "$IMAGE_NAME" >/dev/null \
    && echo "Started container $CONTAINER_NAME using port $port" \
    || { echo "Error starting container $CONTAINER_NAME using port $port"; exit 1; }

check_db_init

echo "Setting up database..."
curl "$DB_SCHEMA_URL" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
echo "DROP USER '$MYSQL_USER'@'localhost';" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
curl "$DB_DATA_URL" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'

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
echo "GRANT REPLICATION CLIENT ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'

echo "Done."
