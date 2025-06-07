#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FLODER
echo "script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [$USERID -ne 0]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

#validate functions taken input as exit status, what command they tired to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $R" | tee -a $LOG_FILE
        exit 1
    fi
}
 
echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop RABBITMQ_PASSWD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script exection completed successfully, $y taken: $TOTAL_TIME $N" | tee -a $LOG_FILE