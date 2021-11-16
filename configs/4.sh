#!/bin/bash
# Read machine constants
# Configurate needed parameters
# Execute configuration
source machine_info.sh;

declare -A machines;
get_machines $1 machines;

project=$1
shift
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


function config_machine()
{
	machine=$1
	script=$2
	shift 2
	echo "./run_remotely.sh" "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
	./run_remotely.sh "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
}

echo "Configuration 1 starting."

# Machine 1 - mySQL Master
config_machine $machine1 mysql-master $db_master_port

# Machine 2 - mySQL Slave
config_machine $machine2 mysql-slave $db_slave_port $db_master_hostname $db_master_port

# Machine 3 - REST POST/PUT/RELETE
config_machine $machine3 spring-petclinic-rest $api_post_port $db_master_hostname $db_master_port - -

# Machine 4 - REST GET
config_machine $machine4 spring-petclinic-rest $api_get_port $db_slave_hostname $db_slave_port - -

# Machine 5 - Ngnix Load Balancer
config_machine $machine5 nginx-load-balancer $api_port $api_get_hostname $api_get_port $api_post_hostname $api_post_port

# Machine 6 - Angular
config_machine $machine6 spring-petclinic-angular $angular_port $api_hostname $api_port
