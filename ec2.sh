#!/bin/bash

LANG=c date +%Y%m%d

TAG_DATE=`LANG=c date +%Y%m%d`
TAG_ENDDATE=`LANG=c date -v +7d +%m%d%Y`
TAG_PROJECT=cdp_workshop
TAG_OWNER=ykono@cloudera.com

TAG_SPECS="ResourceType=instance,Tags=[\
{Key=Name,Value=ykono-single-cluster_${TAG_DATE}},\
{Key=owner,Value=${TAG_OWNER}},\
{Key=enddate,Value=${TAG_ENDDATE}},\
{Key=project,Value=${TAG_PROJECT}}]"

REGION=ap-northeast-1
MSG_DRYRUN_EXPECTED="Request would have succeeded, but DryRun flag is set"

MSG_DRYRUN=$(aws ec2 run-instances --dry-run --region $REGION \
  --tag-specifications $TAG_SPECS \
  --cli-input-json file://ec2.json 2>&1 )

echo $MSG_DRYRUN

if [[ $MSG_DRYRUN = *$MSG_DRYRUN_EXPECTED* ]]; then
   echo "Dry Run Succeeded."
else
   echo "Dry Run Failed."
   exit
fi

INSTANCE_ID=$(aws ec2 run-instances --region $REGION \
  --tag-specifications $TAG_SPECS \
  --query 'Instances[].InstanceId' \
  --output text \
  --user-data=file://"init.sh" \
  --cli-input-json file://ec2.json)

echo $?
echo Instance ID: $INSTANCE_ID

aws ec2 wait instance-running --instance-ids $INSTANCE_ID; echo 'Instance is prepared.'
aws ec2 modify-instance-attribute \
   --instance-id $INSTANCE_ID \
   --no-disable-api-termination
