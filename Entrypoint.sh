#!/bin/bash

export PATH=$PATH:/opt/keycloak/bin/

if [ "$1" = "import" ]; then
    echo "Performing import..."
    mkdir -p /home/default/TEMP_IMPORT_DIR
    cp -r /home/default/IMPORT_DIR/* /home/default/TEMP_IMPORT_DIR
    export WORK_DIRECTORY=/home/default/TEMP_IMPORT_DIR
    user-import.sh
elif [ "$1" = "export" ]; then
    echo "Performing export..."
    export WORK_DIRECTORY=/home/default/EXPORT_DIR
    user-export.sh
else
    echo "Invalid argument provided."
fi