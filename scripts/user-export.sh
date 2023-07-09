#!/bin/bash

export ALL_USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json

# check for missing variables
variables=("EXPORT_KEYCLOAK_SERVER" "EXPORT_REALM" "EXPORT_TOKEN"
        "WORK_DIRECTORY" "ALL_USERS_FILE")

for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "All variables are set"



rm -rf $WORK_DIRECTORY
mkdir $WORK_DIRECTORY

echo "starting exporter"
ERROR_COUNT=0
# Get users as single json
kcadm.sh get users -r $EXPORT_REALM -F id,username --realm $EXPORT_REALM --server $EXPORT_KEYCLOAK_SERVER --token $EXPORT_TOKEN --no-config > $ALL_USERS_FILE

# For each user, get role mappings, group memberships and user attributes and append it to the respective user entry
users=$(cat $ALL_USERS_FILE | jq -c '.[]')

# For each user id&name get groups paths and full user definition relevant attributes
for user in $users
do
  # Get user id
  user_id=$(echo $user | jq -r '.id')

  # Get username
  username=$(echo $user | jq -r '.username')

  # Display user information for understanding
  echo "Getting user groups for userID=$user_id username=$username"

  # Create a directory for each user 
  mkdir -p $WORK_DIRECTORY/$username

  # Get full user json excluding the id and timestamp
  kcadm.sh get users/$user_id --fields '*(*(*(*(*(*))))),-id,-createdTimestamp' --realm $EXPORT_REALM --server $EXPORT_KEYCLOAK_SERVER --token $EXPORT_TOKEN --no-config > $WORK_DIRECTORY/$username/USER.json

  # If failed to get user, skip the current iteration
  if [ $? -ne 0 ]; then
      echo "Failed to get the user with ID=$user_id"
      ((ERROR_COUNT++))
      continue
  fi

  # Get the paths of all groups the current user is a member of and save into separate csv file (space separated)
  kcadm.sh get users/$user_id/groups -F path --format CSV  --realm $EXPORT_REALM --server $EXPORT_KEYCLOAK_SERVER --token $EXPORT_TOKEN --no-config > $WORK_DIRECTORY/$username/group_paths.csv

  # If failed, skip the rest, (for now there is no rest)
  if [ $? -ne 0 ]; then
      echo "Failed to get the groups of the user with ID=$user_id"
      ((ERROR_COUNT++))
      continue
  fi

  echo "Successfully exported user $username"
done

echo cleaning up temp files 
echo removing $ALL_USERS_FILE
rm -rf $ALL_USERS_FILE

echo finished the export proccess successfully with $ERROR_COUNT errors