#! /bin/bash

# yum update
yum -y update

# Japan Timezone
sed -i -e "/ZONE=/s/.*/ZONE=\"Asia\/Tokyo\"/g" /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Auto Shutdown
echo "0 22 * * * root yum -y update && /sbin/shutdown -h now" >> /etc/crontab

# Install SSM (Please note: amazon-ssm-ap-northeast-1 is for the resion)
yum -y update
curl https://amazon-ssm-ap-northeast-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o amazon-ssm-agent.rpm
yum install -y amazon-ssm-agent.rpm

yum install -y git

# Reboot for the timezone change
shutdown -r now
