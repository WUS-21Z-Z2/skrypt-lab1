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
db_master_port=${arg_array[4]}
db_slave_port=${arg_array[5]}
api_port=${arg_array[6]}
angular_port=${arg_array[7]}
db_master_hostname=${machines["$machine1,internal_ip"]}
db_slave_hostname=${machines["$machine2,internal_ip"]}
api_hostname=${machines["$machine3,external_ip"]}


echo "Configuration 1 starting."

# Machine 1 - mySQL Master
config_machine $machine1 mysql-master $db_master_port

# Machine 2 - mySQL Slave
config_machine $machine2 mysql-slave $db_slave_port $db_master_hostname $db_master_port

# Machine 3 - REST
config_machine $machine3 spring-petclinic-rest-write $api_port $db_master_hostname $db_master_port $db_slave_hostname $db_slave_port

# Machine 4 - Angular
config_machine $machine4 spring-petclinic-angular $angular_port $api_hostname $api_port
