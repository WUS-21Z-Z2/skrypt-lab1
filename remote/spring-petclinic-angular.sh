#!/bin/bash
port=$1
api_hostname=$2
api_port=$3

sudo docker rmi dove6/spring-petclinic-angular:latest
petclinic_angular_id=$(sudo docker run --rm -d -p $port:8080 -e REST_API_HOSTNAME=$api_hostname -e REST_API_PORT=$api_port dove6/spring-petclinic-angular:latest)
echo "Started container $petclinic_angular_id using port $port"
