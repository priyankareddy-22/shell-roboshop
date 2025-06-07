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

dnf install maven -y
VALIDATE $? "Installing maven and java"

id roboshop
if [ $? -ne 0]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir /app
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping shipping"

mvn clean package
VALIDATE $? "Packaging the shipping application"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving and renaming jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting Shipping"

dnf install mysql -y 
VALIDATE $? "Install MYSQL"

mysql -h mysql.priya22n.site -u root -ppRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]
then
    mysql -h mysql.priya22n.site -uroot -MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.priya22n.site  -uroot -MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE 
    mysql -h mysql.priya22n.site  -uroot -MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Data is already loaded into MYSQL ... $Y SKIPPING $N"
fi
END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $y taken: $TOTAL_TIME $N" | tee -a $LOG_FILE