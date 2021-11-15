#!/bin/bash
port=$1
database_hostname=$2
database_port=$3

sudo docker rmi dove6/spring-petclinic-rest-mysql:latest
petclinic_rest_id=$(sudo docker run --rm -d -p $port:9966 dove6/spring-petclinic-rest-mysql:latest "--spring.datasource.url=jdbc:mysql://$database_hostname:$database_port/petclinic?useUnicode=true")
echo "Started container $petclinic_rest_id using port $port"
