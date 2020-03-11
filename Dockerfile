FROM sl:7

ADD cvmfs/cernvm.repo /etc/yum.repos.d/cernvm.repo
ADD cvmfs/default.local /etc/cvmfs/default.local

RUN yum update -y \
    && yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm \
    && yum -y install openssh-server cvmfs man freetype openssl098e libXpm libXext wget git tcl \
       perl-ExtUtils-Embed perl-libwww-perl compat-libstdc++-33 \
    && yum clean all \
    && rm -rf /tmp/.X* \
    && for repo in cms.cern.ch cms-ib.cern.ch oasis.opensciencegrid.org \
       	   cms-lpc.opensciencegrid.org sft.cern.ch cms-bril.cern.ch cms-opendata-conddb.cern.ch; \
	   do mkdir /cvmfs/$repo; echo "$repo /cvmfs/$repo cvmfs defaults 0 0" >> /etc/fstab; \
	done 

WORKDIR /root
ADD cvmfs/append_to_bashrc.sh .append_to_bashrc.sh
RUN cat .append_to_bashrc.sh >> .bashrc

ADD cvmfs/run.sh /run.sh
ADD cvmfs/mount_cvmfs.sh /mount_cvmfs.sh
ENTRYPOINT ["/run.sh"]
CMD ["/bin/bash"]
