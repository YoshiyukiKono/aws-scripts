TODO

Disable the tuned Service
If your cluster hosts are running RHEL/CentOS 7.x, disable the "tuned" service by running the following commands:
Ensure that the tuned service is started:
systemctl start tuned
Turn the tuned service off:
tuned-adm off
Ensure that there are no active profiles:
tuned-adm list
The output should contain the following line:
No current active profile
Shutdown and disable the tuned service:
systemctl stop tuned
systemctl disable tuned

https://docs.cloudera.com/documentation/enterprise/latest/topics/cdh_admin_performance.html#cdh_performance__section_hw3_sdf_jq

