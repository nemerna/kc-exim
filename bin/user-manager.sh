# #!/bin/bash

action="$1"

case "$action" in
    "export")

        export ALL_USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json

        # check for missing variables
        variables=("EXPORT_KEYCLOAK_SERVER" "EXPORT_REALM"
                "EXPORT_CLIENT" "EXPORT_SECRET"
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


        # Login to Keycloak EXPORT SERVER

        echo $EXPORT_SECRET|kcadm.sh config credentials --server $EXPORT_KEYCLOAK_SERVER --realm $EXPORT_REALM --client $EXPORT_CLIENT


        # run the exporter
        user-exporter.sh
        ;;
    "import")

        export ALL_GROUPS_FILE=${WORK_DIRECTORY}/IMPORT_SERVER_GROUPS.json

        # check for missing variables
        variables=("IMPORT_KEYCLOAK_SERVER" "IMPORT_REALM"
                "IMPORT_CLIENT" "IMPORT_SECRET"
                "WORK_DIRECTORY" "ALL_GROUPS_FILE")

        for var in "${variables[@]}"; do
            if [ -z "${!var}" ]; then
                echo "Error: $var is not set"
                exit 1
            fi
        done

        echo "All variables are set"

        # Login to Keycloak IMPORT SERVER
        echo $IMPORT_SECRET|kcadm.sh config credentials --server $IMPORT_KEYCLOAK_SERVER --realm $IMPORT_REALM --client $IMPORT_CLIENT

        # get all groups of the target import server
        kcadm.sh get groups > ${ALL_GROUPS_FILE}

        # run the groups wrapper
        groups-ids-wrapper.sh

        # run the importer
        user_importer.sh

        ;;
    "migrate")

        export ALL_USERS_FILE=${WORK_DIRECTORY}/EXPORT_SERVER_USERS.json
        export ALL_GROUPS_FILE=${WORK_DIRECTORY}/IMPORT_SERVER_GROUPS.json

        # check for missing variables
        variables=("IMPORT_KEYCLOAK_SERVER" "EXPORT_KEYCLOAK_SERVER" "IMPORT_REALM" "EXPORT_REALM"
                "IMPORT_CLIENT" "EXPORT_CLIENT" "IMPORT_SECRET" "EXPORT_SECRET"
                "WORK_DIRECTORY" "WORK_DIRECTORY" "ALL_USERS_FILE" "ALL_GROUPS_FILE")

        for var in "${variables[@]}"; do
            if [ -z "${!var}" ]; then
                echo "Error: $var is not set"
                exit 1
            fi
        done

        echo "All variables are set"



        rm -rf $WORK_DIRECTORY
        mkdir $WORK_DIRECTORY
        rm -rf $WORK_DIRECTORY
        mkdir $WORK_DIRECTORY




        # Login to Keycloak EXPORT SERVER

        echo $EXPORT_SECRET|kcadm.sh config credentials --server $EXPORT_KEYCLOAK_SERVER --realm $EXPORT_REALM --client $EXPORT_CLIENT


        # run the exporter
        user-exporter.sh


        # Login to Keycloak IMPORT SERVER
        echo $IMPORT_SECRET|kcadm.sh config credentials --server $IMPORT_KEYCLOAK_SERVER --realm $IMPORT_REALM --client $IMPORT_CLIENT

        # get all groups of the target import server
        kcadm.sh get groups > ${ALL_GROUPS_FILE}

        # run the groups wrapper
        groups-ids-wrapper.sh

        # run the importer
        user_importer.sh
        ;;
    *)
        # Invalid action
        echo "Invalid argument. Please provide 'export', 'import', or 'migrate' as the argument."
        exit 1
        ;;
esac
