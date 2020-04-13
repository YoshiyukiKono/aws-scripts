#!/bin/sh

CM_USERNAME=admin
CM_PASSWORD=admin
DEPLOYMENT_PORT=7180

DEPLOYMENT_HOST=<YOUR DEPLOYMENT/CM HOST>

DEPLOYMENT_HOST_PORT=$DEPLOYMENT_HOST:$DEPLOYMENT_PORT

# logging stdout/stderr
set -x
exec >> /root/postcreate-license.log 2>&1
date


cat <<EOF > my_cloudera_license.txt
<COPY YOUR LICENSE CONTENTS>
EOF


curl -s -X POST -F 'license=@my_cloudera_license.txt' -u ${CM_USERNAME}:${CM_PASSWORD} http://${DEPLOYMENT_HOST_PORT}/api/v19/cm/license

exit 0
