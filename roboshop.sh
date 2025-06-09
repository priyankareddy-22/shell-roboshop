#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c704820e242a6aaf"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09866222OKAR1PLMNXKY"
DOMAIN_NAME="priya22n.site"

#for instance in ${INSTANCES[@]}
for instance in ${INSTANCES[@]}
do 
   
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0c704820e242a6aaf --tag-specification "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --Output text)
   
  if [ $instance != "frontend" ]
  then
    Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].
    Instance[0].PrivateIpAddress" --output text)
  else 
    Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].
    Instance[0].PublicIpAddress" --output text)
  fi
  echo "$instance Ip address: $IP"
done
