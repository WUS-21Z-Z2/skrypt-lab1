#!/bin/bash
# Parse the structure into individual setups
# Start a session for each setup and launch it with provided arguments

# Flags:
# -p <name>     set the project name
# -z <name>     set the zone name
# -m <name>     set the machine name
# -s <script> <args>    add a remote script for the current project, zone, machine combination

setups=()

# Collapse structure to setups
while (($# > 0))
do
    new_script=false
    flag=$1
    shift
    case $flag in
        -p) # Project
            project=$1
            shift
            ;;
        -z) # Zone
            zone=$1
            shift
            ;;
        -m) # Machine
            machine=$1
            shift
            ;;
        -s) # Script
            script=$1
            args=$2
            if [ -z "$project" ] || [ -z "$zone" ] || [ -z "$machine" ]
            then
                echo "Command '$script' with arguments '$args' is missing project, zone and/or machine. Make sure to define those first."
                exit 1
            fi
            new_script=true
            shift 2
            ;;
        *) # Invalid arguments
            echo "Invalid option '$flag'."
            exit 2
            ;;
    esac
    if [ "$new_script" = true ]
    then
        # Store the setup configuration
        setup=("$project" "$zone" "$machine" "$script" "$args")
        setups+=("${setup[@]}")
        echo "Registered setup {project: '$project', zone: '$zone', machine: '$machine', command: '$script', arguments: '$args'}"
    fi
done

# Stop execution if no setups were generated
if ((${#setups[@]} == 0))
then
    echo "You need at least 1 command-arguments pair."
    exit 3
fi
echo

set "${setups[@]}"

# Start a session for each setup
while (($# > 0))
do
    ./session.sh $1 $2 $3 $4 $5
    shift 5
done

exit 0