#!/bin/bash

chmod o+rw /dev/fuse
source /mount_cvmfs.sh
mount_cvmfs
exec "$@"
