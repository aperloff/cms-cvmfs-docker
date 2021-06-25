#!/bin/bash

chmod o+rw /dev/fuse

if [ -z "$MY_UID" ]; then
    MY_UID=$(id -u cmsusr)
    echo "MY_UID variable not specified, defaulting to cmsusr user id ($MY_UID)"
fi

if [ -z "$MY_GID" ]; then
    MY_GID=$(id -g cmsusr)
    echo "MY_GID variable not specified, defaulting to cmsusr user group id ($MY_GID)"
fi

FIND_GROUP=$(grep ":$MY_GID:" /etc/group)

if [ -z "$FIND_GROUP" ]; then
    usermod -g users cmsusr
    groupdel cmsusr
    groupadd -g $MY_GID cmsusr
fi

# Set cmsusr account's UID.
usermod -u $MY_UID -g $MY_GID --non-unique cmsusr > /dev/null 2>&1

# Change ownership to cmsusr account on all working folders.
chown -R $MY_UID:$MY_GID /home/cmsusr

source /mount_cvmfs.sh
mount_cvmfs

#trap : TERM INT; sleep infinity & wait
su cmsusr -s /bin/bash "$@"
