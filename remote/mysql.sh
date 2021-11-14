#!/bin/bash
port=$1

mysql_id=$(sudo docker run --rm -d --name mysql-petclinic -e MYSQL_ROOT_PASSWORD=petclinic -e MYSQL_USER=pc -e MYSQL_PASSWORD=petclinic -e MYSQL_DATABASE=petclinic -p $port:3306 mysql:5.7.8)
echo "Started container $mysql_id using port $port"
while true
do
	echo 'exit' | sudo docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' 2>&1 | grep -e 'ERROR 1045' -e 'ERROR 2002' || break
	sleep 1
done
curl https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql | sudo docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
curl https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql | sudo docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
