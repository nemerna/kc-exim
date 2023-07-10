#!/bin/bash
export USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json

# Define the temporary file for storing updated users
temp_file=$(mktemp)

# Check for missing variables
variables=("EXPORT_KEYCLOAK_SERVER" "EXPORT_REALM" "EXPORT_TOKEN" "WORK_DIRECTORY" "USERS_FILE")

for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "All variables are set"

echo "Starting exporter"
ERROR_COUNT=0
EXPORTED_USERS_COUNT=0

# Get users as single JSON
kcadm.sh get users -r "$EXPORT_REALM" -F '*(*(*(*(*(*))))),-createdTimestamp' --realm "$EXPORT_REALM" --server "$EXPORT_KEYCLOAK_SERVER" --token "$EXPORT_TOKEN" --no-config > "$USERS_FILE"

if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to Export Users\e[0m"
    exit 1
fi

# For each user, get role mappings, group memberships, and user attributes, and append them to the respective user entry
while IFS= read -r user; do
    # Get user id and username
    user_id=$(echo "$user" | jq -r '.id')
    username=$(echo "$user" | jq -r '.username')

    # Get user group paths
    REMOTE_GROUPS=$(kcadm.sh get "users/$user_id/groups" -F path --realm "$EXPORT_REALM" --server "$EXPORT_KEYCLOAK_SERVER" --token "$EXPORT_TOKEN" --no-config)

    # If failed to get user groups, skip the current iteration
    if [ $? -ne 0 ]; then
        echo "Failed to get groups for user with ID=$user_id, leaving groups empty"
        ((ERROR_COUNT++))
        continue
    fi

    # Turn the user groups into a comma-separated array
    GROUPS_ARRAY=$(echo "$REMOTE_GROUPS" | jq -r '.[].path' | jq -sR 'split("\n")[:-1]')

    # Update Single User JSON to include the "groups" key and its value
    UPDATED_USER=$(echo "$user" | jq --argjson groups "$GROUPS_ARRAY" 'if has("groups") then .groups = $groups else . + { "groups": $groups } end')

    # Add the updated user to the temporary file
    echo "$UPDATED_USER" >> "$temp_file"

    echo "Successfully exported user $username"
    ((EXPORTED_USERS_COUNT++))
done < <(jq -c '.[]' "$USERS_FILE")

# Move the temporary file to the final output file
jq -s '.' "$temp_file" > "$USERS_FILE"
rm -f $temp_file
echo -e "Export Process Finished \nSuccessfully made Full Export for: $EXPORTED_USERS_COUNT Users.\nPartially exported: $ERROR_COUNT Users.\n"
