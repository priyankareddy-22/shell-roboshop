# #!/bin/bash
# AMI_ID="ami-09c813fb71547fc4f"
# SG_ID="sg-0c704820e242a6aaf"
# INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
# ZONE_ID="Z09866222OKAR1PLMNXKY"
# DOMAIN_NAME="priya22n.site"

# #for instance in ${INSTANCES[@]}
# for instance in $@
# do 
   
#   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0c704820e242a6aaf --tag-specification "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
   
#   if [ $instance != "frontend" ]
#   then
#     Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instance[0].PrivateIpAddress" --output text)
#   else 
#     Ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instance[0].PublicIpAddress" --output text)
#   fi
#   echo "$instance Ip address: $IP"
# done
#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c704820e242a6aaf" # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09866222OKAR1PLMNXKY" # replace with your ZONE ID
DOMAIN_NAME="priya22n.site" # replace with your domain

#for instance in ${INSTANCES[@]}
for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0c704820e242a6aaf --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instance IP address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating or Updating a record set for cognito endpoint"
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