#!/bin/bash
# Copy all scripts to the machine
# Run one of them with parameters
# Remove the scripts

# Args:
# $1    gcloud project
# $2    gcloud zone
# $3    gcloud machine
# $4    script name (from ./remote_scripts/) to execute
# $5+   arguments for the script

project=$1
zone=$2
machine=$3
script=$4
shift 4

gcloud beta compute scp --project=$project --zone=$zone --recurse './remote_scripts' $machine:'~/.remote_scripts'
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 1. Nothing needs cleanup."
    exit 1
fi

gcloud beta compute ssh --project=$project --zone=$zone $machine --command="bash ~/.remote_scripts/$script.sh $*"
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 2. './.remote_scripts' was not deleted."
    exit 2
fi

gcloud beta compute ssh --project=$project --zone=$zone $machine --command='rm -r ./.remote_scripts'
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 3. './.remote_scripts' was not deleted."
    exit 3
fi

exit 0