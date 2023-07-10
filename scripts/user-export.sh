#!/bin/bash

export USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json

# check for missing variables
variables=("EXPORT_KEYCLOAK_SERVER" "EXPORT_REALM" "EXPORT_TOKEN"
        "WORK_DIRECTORY" "USERS_FILE")

for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "All variables are set"

echo "starting exporter"
ERROR_COUNT=0
EXPORTED_USERS_COUNT=0
# Get users as single json
kcadm.sh get users -r $EXPORT_REALM -F '*(*(*(*(*(*))))),-createdTimestamp' --realm $EXPORT_REALM --server $EXPORT_KEYCLOAK_SERVER --token $EXPORT_TOKEN --no-config > $USERS_FILE
if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to Export Users\e[0m"
    exit 1
fi
# For each user, get role mappings, group memberships and user attributes and append it to the respective user entry
users=$(cat $USERS_FILE | jq -c '.[]')

# For each user id&name get groups paths and full user definition relevant attributes
for user in $users
do
  # Get user id
  user_id=$(echo $user | jq -r '.id')
  
  username=$(echo $user | jq -r '.username')

  # Get a single user group paths
  REMOTE_GROUPS=$(kcadm.sh get users/$user_id/groups -F path  --realm $EXPORT_REALM --server $EXPORT_KEYCLOAK_SERVER --token $EXPORT_TOKEN --no-config )

  # If failed to get user, skip the current iteration
  if [ $? -ne 0 ]; then
      echo "Failed to get groups for user with ID=$user_id,   leaving groups empty"
      ((ERROR_COUNT++))
      UPDATED_USERS+=("$UPDATED_USER")
      continue
  fi
  # Turn the user Groups into comma separated
  GROUPS_ARRAY=$(echo "$REMOTE_GROUPS" | jq -r '.[].path' | jq -sR 'split("\n")[:-1]') 

  # Update Single User JSON to include the "groups" key and its value
  UPDATED_USER=$(echo "$user" | jq --argjson groups "$GROUPS_ARRAY" 'if has("groups") then .groups = $groups else . + { "groups": $groups } end')

  # Add the updated user to the users array
  UPDATED_USERS+=("$UPDATED_USER")

  echo "Successfully exported user $username"
  ((EXPORTED_USERS_COUNT++))
done

echo "${UPDATED_USERS[*]}" | jq -s '.' > $USERS_FILE
echo -e "Export Proccess Finished \nSuccessfully made Full Export for: $EXPORTED_USERS_COUNT Users.\n partially exported: $ERROR_COUNT Users.\n"