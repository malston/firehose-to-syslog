#!/bin/bash

INSTANCES=$1
HOSTNAME=$2

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo "Usage: ./deploy-manifest.sh <number_of_instances> <hostname>"
	exit 1
fi

cf push -i $INSTANCES -n $HOSTNAME --no-route
