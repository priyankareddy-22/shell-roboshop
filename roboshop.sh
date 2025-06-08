#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01d79933c960fd126"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z043242732NAEK996K9L7"
DOMAIN_NAME="priya22n.site"

#for instance in ${INSTANCES[@]}
for instance in ${INSTANCES[@]}
do 
   
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01d79933c960fd126 --tag-specification "ResourceType=instance, Tags=[{Key=Name, Value=test}]" --query "Instance[0].privateIpAddress" --Output text)


  if [ $instance != "frontend" ]
  then
 IP=$(aws ec2 describe-instances --instance-ids INSTANCE_ID --query "Resrevations [0].Instances[0].privateIpAddress"
 --output text)
RECORD_NAME=""$instance.$DOMAIN_NAME"
else
IP=$(aws ec2 describe-instances --instance-ids INSTANCE_ID --query "Resrevations [0].Instances[0].publicIpAddress"
--output text)
RECORD_NAME= "$DOMAIN_NAME"
fi
echo "$instance IP address: $IP"
 
 aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID\
--change-batch '


{
    "Comment": "Creating OR Updating a record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }'
done