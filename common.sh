#!/bin/bash

USERID=$(id -u)

START_TIME=$(date +%s)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FLODER
echo "script started executing at: $(date)" | tee -a $LOG_FILE

app_setup(){
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

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    cd /app
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping $app_name"
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"
    
    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

systemd_setup(){
        cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? " Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    
    systemctl start $app_name
    VALIDATE $? "Staring $app_name"
    
}
check_root(){
    if [$USERID -ne 0]
    then
     echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}
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

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed successfully, $Y Time taken: $TOTALTIME second $N"
} 