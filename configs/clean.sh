#!/bin/bash
# Read machine constants
# Configurate needed parameters
# Execute configuration
source machine_info.sh;

declare -A machines;
get_machines $1 machines;

project=$1
shift


echo "Cleaning started."

for i in $(seq 1 ${machines[count]})
do
    echo "Cleaning machine $i started."
    config_machine $project $i clean
    echo "Cleaning machine $i done."
done

echo "Cleaning done."