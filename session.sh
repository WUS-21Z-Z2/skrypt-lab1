#!/bin/bash
# Start a session with the virtual machine and
# remotely execute a script with arguments

# Args:
# $1    gcloud project
# $2    gcloud zone
# $3    gcloud machine
# $4    script name (from ./remote/) to execute
# $5+   arguments for the script

project=$1
zone=$2
machine=$3
shift 3
cmd="./remote_scripts/$1.sh"
shift
args=$*
# Print the command that will get executed, useful for manual testing
#echo "gcloud beta compute ssh --project \"$project\" --zone \"$zone\" \"$machine\" --command \"bash -s $args\" < $cmd"
gcloud beta compute ssh --project "$project" --zone "$zone" "$machine" --command "bash -s -- $args" < $cmd
if (($? > 0))
then
    echo "Failed to connect to '$project/$zone/$machine'"
    exit 1
fi
exit 0