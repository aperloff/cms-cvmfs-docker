
# add some aliases that don't exist by default in this container
alias lla='ll -ah'

# Source some CMS/VOMS specific setup scripts
source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el6-x86_64/setup.sh

# Needed to access FNAL EOS
export XrdSecGSISRVNAMES="cmseos.fnal.gov"
