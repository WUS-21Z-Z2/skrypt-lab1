#!/bin/bash
# Read machine constants
# Configurate needed parameters
# Execute configuration
source machine_info.sh;

declare -A machines;
get_machines $1 machines;

project=$1
shift

function config_machine()
{
	machine=$1
	script=$2
	shift 2
	echo "./run_remotely.sh" "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
	./run_remotely.sh "$project" "${machines["$machine,zone"]}" "${machines["$machine,name"]}" "$script" "$*"
}

echo "Cleaning started."

for i in $(seq 1 ${machines[count]})
do
    echo "Cleaning machine $i started."
    config_machine $i clean
    echo "Cleaning machine $i done."
done

echo "Cleaning done."