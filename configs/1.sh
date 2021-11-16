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
db_port=${arg_array[3]}
api_port=${arg_array[4]}
angular_port=${arg_array[5]}
db_hostname=${machines["$machine1,internal_ip"]}
api_hostname=${machines["$machine2,external_ip"]}


function config_machine()
{
	machine=$1
	script=$2
	shift 2
	echo "./run_remotely.sh" "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
	./run_remotely.sh "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
}

echo "Configuration 1 starting."

# Machine 1 - mySQL
config_machine $machine1 mysql-master $db_port

# Machine 2 - REST
config_machine $machine2 spring-petclinic-rest $api_port $db_hostname $db_port - -

# Machine 3 - Angular
config_machine $machine3 spring-petclinic-angular $angular_port $api_hostname $api_port
