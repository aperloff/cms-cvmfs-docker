
# add some aliases that don't exist by default in this container
alias lla='ll -ah'
alias voms-proxy-init='voms-proxy-init -voms cms --valid 192:00 -cert ~/.globus/usercert.pem -key ~/.globus/userkey.pem'

# Check to see if the cvmfs folders are mounted
echo -ne "Checking CVMFS mounts ... "
if cvmfs_config probe ${CVMFS_MOUNTS} >/dev/null; then
    echo -e "DONE"
    if [ -z "$CVMFS_MOUNTS" ]; then
	echo -e "\tAll CVMFS folders mounted"
    elif [ "${CVMFS_MOUNTS,,}" == "none" ] || [ "${CVMFS_MOUNTS}" == " " ] ; then
        echo -ne "Not mounting any filesystems."
    else
	echo -e "\tThe following CVMFS folders have been successfully mounted:"
	for MOUNT in ${CVMFS_MOUNTS[@]}; do
	    echo -e "\t\t${MOUNT}"
	done
    fi
else
    echo -e "DONE\n\tAt least one CVMFS folders is not mounted. Will automatially execute run.sh"
    /mount.sh
fi

# Source some CMS/VOMS specific setup scripts
if [ -f "/cvmfs/cms.cern.ch/cmsset_default.sh" ]; then
    source /cvmfs/cms.cern.ch/cmsset_default.sh
else
    echo -e "Unable to source /cvmfs/cms.cern.ch/cmsset_default.sh"
fi
if [ -f "/cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el6-x86_64/setup.sh" ]; then
    source /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el6-x86_64/setup.sh
else
    echo -e "Unable to setup the grid utilities from /cvmfs/oasis.opensciencegrid.org/"
fi

# Needed to access FNAL EOS
export XrdSecGSISRVNAMES="cmseos.fnal.gov"
