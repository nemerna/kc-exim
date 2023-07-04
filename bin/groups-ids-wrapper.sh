#!/bin/bash

# Function to extract the ID of a group by its path
get_group_id() {
    local group_path=$1
    local id

    # Remove double quotes from the path
    group_path="${group_path%\"}"
    group_path="${group_path#\"}"

    # Use jq's recursive ".." to traverse the JSON structure
    id=$(jq -r --arg path "$group_path" '.. | select(type=="object" and .path?==$path) | .id' $ALL_GROUPS_FILE)

    if [[ $id != "null" ]]; then
        echo $id
        return 0
    fi

    return 1
}

# Iterate over each directory
for user_dir in "$IMPORT_DIRECTORY"/*; do
    # Ensure it's a directory
    if [ -d "$user_dir" ]; then
        # Define the group_paths file for this directory
        group_paths_file="$user_dir/group_paths.csv"
        group_ids_file="$user_dir/GROUP_IDS.csv"
        
        # Read each line from the group_paths file
        while IFS= read -r line || [ -n "$line" ]; do
            # Split the line into paths
            IFS=' ' read -ra paths <<< "$line"
            group_ids_line=""
            for path in "${paths[@]}"; do
                # Get the group ID
                group_id=$(get_group_id "$path")
    
                if [[ -n $group_id ]]; then
                    # Append group id to group_ids_line
                    group_ids_line+="$group_id "
                else
                    echo "Group not found for path: $path"
                fi
            done
            # Output the group IDs to the file
            echo "${group_ids_line% }" >> "$group_ids_file"
        done < "$group_paths_file"
    fi
done
