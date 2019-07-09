#!/bin/bash

#for mountpoint in `grep cvmfs /etc/fstab | awk '{print $2}'`
#do
#    mount $mountpoint
#done
mount -a
trap : TERM INT; sleep infinity & wait
