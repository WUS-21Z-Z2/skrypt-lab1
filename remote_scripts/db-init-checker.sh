function check_db_init {
    echo "$CONTAINER_NAME $MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
    echo -n "Starting database"
    while echo 'exit' | docker exec -i "$CONTAINER_NAME" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' 2>&1 | grep -e 'ERROR 1045' -e 'ERROR 2002' >/dev/null
    do
        echo -n "."
        sleep 1
    done
    echo
}
