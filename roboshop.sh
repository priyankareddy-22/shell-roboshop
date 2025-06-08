#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01d79933c960fd126"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z043242732NAEK996K9L7"
DOMAIN_NAME="priya22n.site"

#for instance in ${INSTANCES[@]}
for instance in ${INSTANCES[@]}
do 
   
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.
  micro --security-group-ids sg-01d79933c960fd126 --tag-specification "ResourceType=instance,
  Tags=[{Key=Name, Value=$instance}]" --query "Instance[0].privateIpAddress" --Output text)
   
  if [ $instance != "frontend"]
  then
    Ip=$(aws ec2 describe-instance --instance-ids $INSTANCE_ID --query "Reservations[0].
    Instance[0].PrivateIpAddress" --output text)
  else 
    Ip=aws ec2 describe-instance --instance-ids $INSTANCE_ID --query "Reservations[0].
    Instance[0].PublicIpAddress" --output text
  fi
  echo "$instance Ip address: $IP"
done
