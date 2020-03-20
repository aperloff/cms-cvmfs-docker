#!/bin/bash

mount_cvmfs() {
    if [ -z "$CVMFS_MOUNTS" ] || [ "${CVMFS_MOUNTS,,}" == "none" ] || [ "${CVMFS_MOUNTS}" == " " ] ; then
	echo -e "Not mounting any filesystems."
    elif [ "${CVMFS_MOUNTS,,}" == "all" ] ; then
	echo -ne "Mounting all filesystems in /etc/fstab ... "
	mount -a -F > /dev/null 2>&1
	echo -e "DONE"
    else
	for MOUNT in ${CVMFS_MOUNTS[@]}; do
            echo -ne "Mounting the filesystem \"${MOUNT}\" ... "
            mount -F ${MOUNT} > /dev/null 2>&1
            echo -e "DONE"
	done
    fi
}
