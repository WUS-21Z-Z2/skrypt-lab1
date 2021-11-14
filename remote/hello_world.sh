#!/bin/bash
# Remote execution test

# Did script get executed at all?
echo "Hello world!"
# Did arguments get passed?
echo "Argument 1: $1"
echo "Argument 2: $2"
shift 2
echo "Other: $*"
# Who did execute this?
echo "$USER"