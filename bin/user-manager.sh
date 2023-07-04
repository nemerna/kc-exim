# #!/bin/bash

export EXPORT_DIRECTORY=./USERMANAGER_EXPORT_${EXPORT_REALM}
export IMPORT_DIRECTORY=./USERMANAGER_IMPORT_${IMPORT_REALM}

export ALL_USERS_FILE=${EXPORT_DIRECTORY}/EXPORT_SERVER_USERS.json
export ALL_GROUPS_FILE=${IMPORT_DIRECTORY}/IMPORT_SERVER_GROUPS.json

# check for missing variables
variables=("IMPORT_KEYCLOAK_SERVER" "EXPORT_KEYCLOAK_SERVER" "IMPORT_REALM" "EXPORT_REALM"
           "IMPORT_CLIENT" "EXPORT_CLIENT" "IMPORT_SECRET" "EXPORT_SECRET"
           "EXPORT_DIRECTORY" "IMPORT_DIRECTORY" "ALL_USERS_FILE" "ALL_GROUPS_FILE")

for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "All variables are set"



rm -rf $EXPORT_DIRECTORY
mkdir $EXPORT_DIRECTORY
rm -rf $IMPORT_DIRECTORY
mkdir $IMPORT_DIRECTORY




# Login to Keycloak EXPORT SERVER

echo $EXPORT_SECRET|./kcadm.sh config credentials --server $EXPORT_KEYCLOAK_SERVER --realm $EXPORT_REALM --client $EXPORT_CLIENT


# run the exporter
./user-exporter.sh


# Login to Keycloak IMPORT SERVER
echo $IMPORT_SECRET|./kcadm.sh config credentials --server $IMPORT_KEYCLOAK_SERVER --realm $IMPORT_REALM --client $IMPORT_CLIENT


# copy the exported users to the import directory

cp -r ${EXPORT_DIRECTORY}/* ${IMPORT_DIRECTORY}


# get all groups of the target import server
./kcadm.sh get groups > ${ALL_GROUPS_FILE}

# run the groups wrapper
./groups-ids-wrapper.sh


echo "sleeping 20 sec until you delete some users, then the importing will start..."
sleep 20
# run the importer
./user_importer.sh
