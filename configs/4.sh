#!/bin/bash
# Read machine constants
# Configurate needed parameters
# Execute configuration
source machine_info.sh;

declare -A machines;
get_machines $1 machines;

project=$1
shift
if [[ "$#" -ne 12 ]]; then
    echo "Options for configuration 4: masterdb_machine_id slavedb_machine_id writeapi_machine_id readapi_machine_id loadbalancer_machine_id angular_machine_id" \
        "masterdb_port slavedb_port writeapi_port readapi_port loadbalancer_port angular_machine_port" >&2
    exit 1
fi
arg_array=( "$@" )
machine1=${arg_array[0]}
machine2=${arg_array[1]}
machine3=${arg_array[2]}
machine4=${arg_array[3]}
machine5=${arg_array[4]}
machine6=${arg_array[5]}
db_master_port=${arg_array[6]}
db_slave_port=${arg_array[7]}
api_post_port=${arg_array[8]}
api_get_port=${arg_array[9]}
api_port=${arg_array[10]}
angular_port=${arg_array[11]}
db_master_hostname=${machines["$machine1,internal_ip"]}
db_slave_hostname=${machines["$machine2,internal_ip"]}
api_post_hostname=${machines["$machine3,internal_ip"]}
api_get_hostname=${machines["$machine4,internal_ip"]}
api_hostname=${machines["$machine5,external_ip"]}
angular_hostname=${machines["$machine6,external_ip"]}


echo "Configuration 1 starting."

# Machine 1 - mySQL Master
config_machine $project $machine1 mysql-master $db_master_port

# Machine 2 - mySQL Slave
config_machine $project $machine2 mysql-slave $db_slave_port $db_master_hostname $db_master_port

# Machine 3 - REST POST/PUT/RELETE
config_machine $project $machine3 spring-petclinic-rest-write $api_post_port $db_master_hostname $db_master_port

# Machine 4 - REST GET
config_machine $project $machine4 spring-petclinic-rest-read $api_get_port $db_slave_hostname $db_slave_port

# Machine 5 - Nginx Load Balancer
config_machine $project $machine5 nginx-load-balancer $api_port $api_get_hostname $api_get_port $api_post_hostname $api_post_port

# Machine 6 - Angular
config_machine $project $machine6 spring-petclinic-angular $angular_port $api_hostname $api_port

echo "Configuration 4 ready: http://$angular_hostname:$angular_port/petclinic"

./configs/test.sh $angular_hostname $angular_port $api_hostname $api_port
