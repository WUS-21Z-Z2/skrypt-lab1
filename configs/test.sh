#!/bin/bash

angular_hostname=$1
angular_port=$2
api_hostname=$3
api_port=$4

# Requesting front-end page
curl -fLs "http://$angular_hostname:$angular_port/petclinic" | grep "SpringPetclinicAngular" >/dev/null \
    || { echo "Could not fetch Angular page" >&2; exit 1; }
echo "Test passed: fetching Angular page"

# Requesting data by REST API
curl -s "http://$api_hostname:$api_port/petclinic/actuator/health" | grep '{"status":"UP"}' >/dev/null \
    || { echo "Could not access REST API healthcheck endpoint" >&2; exit 2; }
old_value=$(curl -s "http://$api_hostname:$api_port/petclinic/api/pettypes/1" | sed 's/{"id":\([0-9]\+\),"name":"\([^"]*\)"}/\2/i') \
    || { echo "Could not retrieve data using REST API" >&2; exit 3; }
echo "Test passed: retrieving data using REST API"

# Modifying data by REST API
new_value="new-$old_value"
curl -fLsX PUT -H "Content-Type: application/json" -d "{\"id\":1,\"name\":\"$new_value\"}" \
        "http://$api_hostname:$api_port/petclinic/api/pettypes/1" >/dev/null \
    || { echo "Could not modify data using REST API" >&2; exit 4; }
retrieved_new_value=$(curl -s "http://$api_hostname:$api_port/petclinic/api/pettypes/1" | sed 's/{"id":\([0-9]\+\),"name":"\([^"]*\)"}/\2/i') \
    || { echo "Could not retrieve data using REST API" >&2; exit 3; }
if [[ "$new_value" != "$retrieved_new_value" ]]
then
    echo "Could not modify data using REST API" >&2
    exit 4
fi
echo "Test passed: data modification using REST API"

# Cleanup
curl -LsX PUT -H "Content-Type: application/json" -d "{\"id\":1,\"name\":\"$old_value\"}" "http://$api_hostname:$api_port/petclinic/api/pettypes/1" 2>&1 >/dev/null

exit 0
