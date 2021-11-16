#!/bin/bash
# Main script
# Chooses the configuration and passes arguments along

# Args:
# $1    gcloud project
# $2    configuration numbers
# $3+   arguments for the configuration

source machine_info.sh;

if [[ $# -le 1 ]]
then
	echo 'Not enough arguments given!';
	exit 1
fi

#while [[ $# > 0 ]]
#do
	flag=$1
	project=$2
	shift 2
	case $flag in
		1) ./configs/1.sh $project $*;;
		3) ./configs/3.sh $project $*;;
		4) ./configs/4.sh $project $*;;
		clean) ./configs/clean.sh $project $*;;
		*) echo 'Incorrect configuration number!';;
	esac
	#shift
#done

exit 0
