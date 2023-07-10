#!/bin/bash
export USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json

# check for missing variables
variables=("IMPORT_KEYCLOAK_SERVER" "IMPORT_TOKEN" "WORK_DIRECTORY")

for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

users=$(cat $USERS_FILE | jq -c '.[]')
ERROR_COUNT=0
IMPORTED_USERS_COUNT=0
# For each user id&name get groups paths and full user definition relevant attributes
for user in $users
do
    echo
    echo "---------------importing user----------------"
    echo "${user}" | jq . 
    echo "${user}" | jq . | kcadm.sh create users -r $IMPORT_REALM --realm $IMPORT_REALM --server $IMPORT_KEYCLOAK_SERVER --token $IMPORT_TOKEN --no-config  -f -
    if [ $? -ne 0 ]; then
    echo "------------Failed To Import------------"
    ((ERROR_COUNT++))
    continue
    fi
    ((IMPORTED_USERS_COUNT++))
    echo "------------successfully imported------------"
    echo
    echo
done
echo -e "\n\nFinished the Import Proccess, Imported:$IMPORTED_USERS_COUNT Users, with $ERROR_COUNT Failed Imports"