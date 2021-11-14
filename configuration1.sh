#!/bin/bash

# MYSQL
mysql_id=$(docker run --rm -d --name mysql-petclinic -e MYSQL_ROOT_PASSWORD=petclinic -e MYSQL_USER=pc -e MYSQL_PASSWORD=petclinic -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:5.7.8)
echo "$mysql_id"
while true
do
	echo 'exit' | docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' 2>&1 | grep -e 'ERROR 1045' -e 'ERROR 2002' || break
	sleep 1
done
curl https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/initDB.sql | docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
curl https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/populateDB.sql | docker exec -i "$mysql_id" sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'

# SPRING REST
mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress }}' "$mysql_id")
docker run --rm -d -p 9966:9966 dove6/spring-petclinic-rest-mysql:latest "--spring.datasource.url=jdbc:mysql://$mysql_ip:3306/petclinic?useUnicode=true"

# ANGULAR
docker run --rm -d -p 8080:8080 dove6/spring-petclinic-angular:latest
