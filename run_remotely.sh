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
args=$*

gcloud beta compute ssh --ssh-flag="-o ConnectTimeout=30" --ssh-flag="-o BatchMode=yes" --ssh-flag="-o StrictHostKeyChecking=no" --project=$project --zone=$zone $machine --command='rm -f -r ~/.remote_scripts'
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 1. '~/.remote_scripts' could not delete."
    exit 1
fi
echo "Step 1 completed for '$project/$zone/$machine'"

gcloud beta compute scp --scp-flag="-o ConnectTimeout=30" --scp-flag="-o BatchMode=yes" --scp-flag="-o StrictHostKeyChecking=no" --project=$project --zone=$zone --recurse './remote_scripts' $machine:'~/.remote_scripts'
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 2. Nothing needs cleanup."
    exit 2
fi
echo "Step 2 completed for '$project/$zone/$machine'"

gcloud beta compute ssh --ssh-flag="-o ConnectTimeout=30" --ssh-flag="-o BatchMode=yes" --ssh-flag="-o StrictHostKeyChecking=no" --project=$project --zone=$zone $machine --command="cd ~/.remote_scripts && sudo bash ./$script.sh $args"
if (($? > 0)); then
    echo "Failed to connect to '$project/$zone/$machine' during phase 3. '~/.remote_scripts' was not deleted."
    exit 3
fi
echo "Step 3 completed for '$project/$zone/$machine'"

exit 0
