#!/bin/bash

for USER_DIR in $(find $IMPORT_DIRECTORY/* -type d)
do
    USER_JSON_FILE="${USER_DIR}/USER.json"
    GROUP_ID_FILE="${USER_DIR}/GROUP_IDS.csv"

    if [[ -f $USER_JSON_FILE ]]
    then
        # Create user from user.json file
        USER_ID=$(./kcadm.sh create users -r $IMPORT_REALM -f $USER_JSON_FILE -i)
        if [ $? -ne 0 ]; then
            #TO-DO handle when user exists, only join him to groups?
            echo "skipping the currently user as it exists , we talk about the dir $USER_JSON_FILE"
            continue
        fi
        if [[ -f $GROUP_ID_FILE ]]
        then
            # Add user to each group from the group_ids.csv file
            while read -r GROUP_ID
            do
                if [[ ! -z "$GROUP_ID" ]]
                then
                    ./kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r kcm -s realm=$IMPORT_REALM -s userId=$USER_ID -s groupId=$GROUP_ID -n
                fi
            done < $GROUP_ID_FILE
        else
            echo "user $USER_DIR with new ID $USER_ID has no groups to join to"
            echo the GROUP FIle is $GROUP_ID_FILE
        fi
    else
        echo "cannot find user file under the path $USER_DIR"
    fi
done
