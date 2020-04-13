#!/bin/sh +x

script=$1
LOG_BASE=$(basename ${1%.*})_`LANG=c date +%y%m%d_%H%M`

NODES=(52.193.38.167 13.230.4.185 13.115.246.62 3.112.220.124 18.177.146.91 18.179.61.86 54.250.84.83)


for node in ${NODES[@]}
do
  ssh centos@$node 'LC_ALL=C sudo bash -s -x  2>&1' < $script
done
