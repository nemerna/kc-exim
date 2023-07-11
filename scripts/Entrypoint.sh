#!/bin/bash

# define common functions
log_finish_date() {
  # Capture the finish time
  local finish_time=$(date +%s)
  local finish_date=$(date)

  # Calculate the duration
  local duration=$((finish_time - start_time))
  local hours=$((duration / 3600))
  local minutes=$(( (duration % 3600) / 60 ))
  local seconds=$((duration % 60))

  # Echo the results
  echo -e "Script duration: $hours hrs $minutes mins $seconds secs.\n\nStart date: $start_date \n\nFinish date: $finish_date"
}

# Define comman variables
export timestamp=$(date "+%Y.%m.%d-%H.%M.%S")
export PATH=$PATH:/opt/keycloak/bin/
start_time=$(date +%s)
start_date=$(date)

if [ -z "$WORK_DIRECTORY" ]; then
  export WORK_DIRECTORY="/home/default/kc-exim"
fi




# Start the proccess

if [ "$1" = "import" ]; then
    user-import.sh 2>&1 | tee "$WORK_DIRECTORY/Logs-import-$IMPORT_REALM-$timestamp"
    log_finish_date | tee -a "$WORK_DIRECTORY/Logs-import-$IMPORT_REALM-$timestamp"
elif [ "$1" = "export" ]; then
    mkdir -p $WORK_DIRECTORY
    user-export.sh 2>&1 | tee "$WORK_DIRECTORY/Logs-import-$EXPORT_REALM-$timestamp"
    log_finish_date | tee -a "$WORK_DIRECTORY/Logs-import-$EXPORT_REALM-$timestamp"
else
    echo "Invalid argument provided."
fi

