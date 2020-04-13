#!/bin/bash -x

#LOG_FILE=$(basename ${0%.*})_`LANG=c date +%y%m%d_%H%M`.log
#exec > ./$LOG_FILE 2>&1

#sudo sysctl -w vm.swappiness=1

#cat /proc/sys/vm/swappiness

sed -i.bak  /usr/lib/tuned/virtual-guest/tuned.conf -e 's/^\(vm.swappiness = .*\)/#\1\nvm.swappiness = 1/'
grep 'vm.swappiness' /usr/lib/tuned/virtual-guest/tuned.conf
