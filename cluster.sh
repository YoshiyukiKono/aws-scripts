#!/bin/bash

LANG=c date +%Y%m%d

KEY_NAME=~/ykono-pse-demo-tokyo

CLI_INPUT_JSON=file://ec2-1a.json

TAG_DATE=`LANG=c date +%Y%m%d`
TAG_DATE_TIME=`LANG=c date +%Y%m%d_%H%M`
TAG_ENDDATE=`LANG=c date -v +7d +%m%d%Y`
TAG_PROJECT=cdp_workshop
TAG_OWNER=ykono@cloudera.com

INSTANCE_NAME=ykono-single-cluster
INSTANCE_FULLNAME="${INSTANCE_NAME}_${TAG_DATE_TIME}"

INSTANCE_TYPE=t2.2xlarge

# GPU Instance (PAY ATTENTION TO THE COST!)
# P3 - NVIDIA Tesla V100 GPU
# P2 - NVIDIA K80 GPU
# G3 - NVIDIA Tesla M60 GPU

# 1GPU vCPU 4, RAM 61G 0.900USD/hr -- 4vCPU would cause insufficient resource for CDSW
#INSTANCE_TYPE_CDSW_GPU=p2.xlarge
# 8GPU vCPU 32, RAM 488G 7.200USD/hr
#INSTANCE_TYPE_CDSW_GPU=p2.8xlarge
# 16GPU vCPU 64, RAM 732G 14.400USD/hr
#INSTANCE_TYPE_CDSW_GPU=p2.16xlarge

#INSTANCE_TYPE=$INSTANCE_TYPE_CDSW_GPU
#INSTANCE_TYPE=$INSTANCE_TYPE_CDSW

TAG_SPECS="ResourceType=instance,Tags=[\
{Key=Name,Value=${INSTANCE_FULLNAME}},\
{Key=owner,Value=${TAG_OWNER}},\
{Key=enddate,Value=${TAG_ENDDATE}},\
{Key=project,Value=${TAG_PROJECT}}]"

REGION=ap-northeast-1
MSG_DRYRUN_EXPECTED="Request would have succeeded, but DryRun flag is set"

MSG_DRYRUN=$(aws ec2 run-instances --dry-run --region $REGION \
  --instance-type $INSTANCE_TYPE \
  --tag-specifications $TAG_SPECS \
  --cli-input-json $CLI_INPUT_JSON 2>&1 )

echo $MSG_DRYRUN

if [[ $MSG_DRYRUN = *$MSG_DRYRUN_EXPECTED* ]]; then
   echo "Dry Run Succeeded."
else
   echo "Dry Run Failed."
   exit
fi

#test
#exit
FILENAME_PASSWORDLESS_SHELL="passwordless_${INSTANCE_NAME}_${TAG_DATE_TIME}.sh"

function create_instance() {

if [ $# -ne 0 ]; then 
  NODE_TYPE=$1
  INSTANCE_FULLNAME="${INSTANCE_NAME}_${TAG_DATE_TIME}_${NODE_TYPE}"
fi

echo $INSTANCE_FULLNAME

TAG_SPECS="ResourceType=instance,Tags=[\
{Key=Name,Value=${INSTANCE_FULLNAME}},\
{Key=owner,Value=${TAG_OWNER}},\
{Key=enddate,Value=${TAG_ENDDATE}},\
{Key=project,Value=${TAG_PROJECT}}]"

echo $TAG_SPECS

INSTANCE_ID=$(aws ec2 run-instances --region $REGION \
  --instance-type $INSTANCE_TYPE \
  --tag-specifications $TAG_SPECS \
  --query 'Instances[].InstanceId' \
  --output text \
  --user-data=file://"init.sh" \
  --cli-input-json $CLI_INPUT_JSON )

echo $?
echo Instance ID: $INSTANCE_ID

aws ec2 wait instance-running --instance-ids $INSTANCE_ID; echo 'Instance is prepared.'
aws ec2 modify-instance-attribute \
   --instance-id $INSTANCE_ID \
   --no-disable-api-termination


PUBLIC_IP=$(aws ec2 describe-instances --instance-id $INSTANCE_ID  --query 'Reservations[].Instances[].PublicIpAddress' --output text)

FILENAME_LOGIN_SHELL="login_${INSTANCE_FULLNAME}.sh"

# Genenate login shell
cat <<EOF > $FILENAME_LOGIN_SHELL
ssh centos@$PUBLIC_IP
#ssh -i $KEY_NAME.pem centos@$PUBLIC_IP
EOF

chmod +x $FILENAME_LOGIN_SHELL
#ssh centos@$PUBLIC_IP lsblk

# Passwordless Login
# ssh-keygen -t rsa
# ssh -i $KEY_NAME.pem centos@$PUBLIC_IP mkdir -p ssh
cat <<EOF >> $FILENAME_PASSWORDLESS_SHELL
cat ~/.ssh/id_rsa.pub | ssh  -o "StrictHostKeyChecking=no" -i $KEY_NAME.pem centos@$PUBLIC_IP 'cat >> .ssh/authorized_keys'
ssh  -o "StrictHostKeyChecking=no" -i $KEY_NAME.pem centos@$PUBLIC_IP 'chmod 700 .ssh; chmod 640 .ssh/authorized_keys'

EOF
}

#NODES=(CM Master1 Worker1 Worker2 Worker3 CDSW)
NODES=(CM Master1 Worker1)
for node in ${NODES[@]}
do
  create_instance $node
done
chmod +x $FILENAME_PASSWORDLESS_SHELL
