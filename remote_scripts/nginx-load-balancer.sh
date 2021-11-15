#!/bin/bash
port=$1
proxy_get_hostname=$2
proxy_get_port=$3
proxy_other_hostname=$4
proxy_other_port=$5

sudo docker rmi dove6/nginx-load-balancer:latest
nginx_balancer_id=$(sudo docker run --rm -it -p $port:80 -e REST_API_READ_HOSTNAME=$proxy_get_hostname -e REST_API_READ_PORT=$proxy_get_port -e REST_API_WRITE_HOSTNAME=$proxy_other_hostname -e REST_API_WRITE_PORT=$proxy_other_port dove6/nginx-load-balancer:latest)
echo "Started container $nginx_balancer_id using port $port"
