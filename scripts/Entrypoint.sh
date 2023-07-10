#!/bin/bash

export PATH=$PATH:/opt/keycloak/bin/
#!/bin/bash

start_time=$(date +%s)
start_date=$(date)


if [ -z "$WORK_DIRECTORY" ]; then
  export WORK_DIRECTORY="/home/default/kc-exim"
fi

if [ "$1" = "import" ]; then
    user-import.sh> $WORK_DIRECTORY/Logs
elif [ "$1" = "export" ]; then
    mkdir -p $WORK_DIRECTORY
    user-export.sh > $WORK_DIRECTORY/Logs
else
    echo "Invalid argument provided." > $WORK_DIRECTORY/Logs
fi


# Log the finish date
finish_time=$(date +%s)
finish_date=$(date)
duration=$((finish_time - start_time))
hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))
echo -e "Script duration: $hours hrs $minutes mins $seconds secs.\n\nStart date: $start_date \n\nFinish date: $finish_date" >> $WORK_DIRECTORY/Logs

