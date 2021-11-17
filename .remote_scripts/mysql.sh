#!/bin/bash
source ./images-list.sh

IMAGE_NAME="${IMAGES[$CONTAINER_NAME]}"

MYSQL_ROOT_PASSWORD="petclinic"
MYSQL_USER="pc"
MYSQL_PASSWORD="petclinic"
MYSQL_DATABASE="petclinic"

DB_SCHEMA_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/29287912f1976ec01fc364e99a5798d6d8a3d6c7/src/main/resources/db/mysql/initDB.sql"
DB_DATA_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/29287912f1976ec01fc364e99a5798d6d8a3d6c7/src/main/resources/db/mysql/populateDB.sql"

docker stop "$CONTAINER_NAME" >/dev/null 2>&1
docker run -d --add-host=host.docker.internal:host-gateway \
        --name "$CONTAINER_NAME" \
        -p $port:3306 \
        -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
        -e MYSQL_USER="$MYSQL_USER" \
        -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
        -e MYSQL_DATABASE="$MYSQL_DATABASE" \
        "$IMAGE_NAME" >/dev/null \
    && echo "Started container $CONTAINER_NAME using port $port" \
    || { echo "Error starting container $CONTAINER_NAME using port $port"; exit 1; }

echo "$CONTAINER_NAME $MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
echo -n "Starting database"
while echo 'exit' | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' 2>&1 | grep -e 'ERROR 1045' -e 'ERROR 2002' >/dev/null
do
    echo -n "."
    sleep 1
done
echo

echo "Setting up database..."
curl "$DB_SCHEMA_URL" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
echo "DROP USER '$MYSQL_USER'@'localhost';" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
curl "$DB_DATA_URL" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
echo "GRANT REPLICATION CLIENT ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;" \
    | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
