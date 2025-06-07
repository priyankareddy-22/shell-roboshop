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

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MYSQL"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Starting MYSQL"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD  &>>$LOG_FILE
VALIDATE $? "Setting MYSQL root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script exection completed successfully, $y taken: $TOTAL_TIME $N" | tee -a $LOG_FILE