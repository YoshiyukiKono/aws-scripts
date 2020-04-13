#!/bin/bash -x

#LOG_FILE=$(basename ${0%.*})_`LANG=c date +%y%m%d_%H%M`.log
#exec > ./$LOG_FILE 2>&1

#cat /etc/rc.d/rc.local
#cat /etc/default/grub

cat /sys/kernel/mm/transparent_hugepage/enabled
cat /sys/kernel/mm/transparent_hugepage/defrag
#ls -l /etc/rc.d/rc.local
