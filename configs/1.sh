#!/bin/bash
# Read machine constants
# Configurate needed parameters
# Execute configuration
source machine_info.sh;

declare -A machines;
get_machines $1 machines;

project=$1
shift
if [[ "$#" -ne 6 ]]; then
    echo "Options for configuration 1: db_machine_id api_machine_id angular_machine_id db_machine_port api_machine_port angular_machine_port" >&2
    exit 1
fi
arg_array=( "$@" )
machine1=${arg_array[0]}
machine2=${arg_array[1]}
machine3=${arg_array[2]}
db_port=${arg_array[3]}
api_port=${arg_array[4]}
angular_port=${arg_array[5]}
db_hostname=${machines["$machine1,internal_ip"]}
api_hostname=${machines["$machine2,external_ip"]}
angular_hostname=${machines["$machine3,external_ip"]}


echo "Configuration 1 starting."

# Machine 1 - mySQL
config_machine $project $machine1 mysql-master $db_port

# Machine 2 - REST
config_machine $project $machine2 spring-petclinic-rest-write $api_port $db_hostname $db_port

# Machine 3 - Angular
config_machine $project $machine3 spring-petclinic-angular $angular_port $api_hostname $api_port

echo "Configuration 1 ready: http://$angular_hostname:$angular_port/petclinic"
