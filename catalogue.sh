#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb Client"

STATUS --host mongodb.priya22n.site --eval 'db .getMongo().getDBNames().indexOf("catalogue")
if [$STATUS -lt 0]
then
    mongosh --host mongodb.priya22n.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else 
    echo -e "Data is already loaded ...$Y SKIPPING $N"
fi   

print_time