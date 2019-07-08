FROM centos:6

ADD cvmfs/cernvm.repo /etc/yum.repos.d/cernvm.repo
RUN yum install emacs nano cvmfs man freetype openssl098e libXpm libXext wget git  tcsh zsh tcl  perl-ExtUtils-Embed perl-libwww-perl  compat-libstdc++-33  libXmu  libXpm  zip e2fsprogs krb5-devel krb5-workstation  strace libXft xdm ImageMagick ImageMagick-devel mesa-libGL mesa-libGLU glx-utils -y

RUN wget https://www.itzgeek.com/msttcore-fonts-2.0-3.noarch.rpm && \
    rpm -Uvh msttcore-fonts-2.0-3.noarch.rpm && \
    rm msttcore-fonts-2.0-3.noarch.rpm

ADD cvmfs/default.local /etc/cvmfs/default.local

RUN  mkdir .globus && \
     chmod 0700 .globus && \
     mkdir /cvmfs/cms.cern.ch && \
     echo "cms.cern.ch /cvmfs/cms.cern.ch cvmfs defaults 0 0" >> /etc/fstab && \
     mkdir /cvmfs/cms-ib.cern.ch  && \
     echo "cms-ib.cern.ch /cvmfs/cms-ib.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/oasis.opensciencegrid.org  && \
     echo "oasis.opensciencegrid.org /cvmfs/oasis.opensciencegrid.org cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-lpc.opensciencegrid.org  && \
     echo "cms-lpc.opensciencegrid.org /cvmfs/cms-lpc.opensciencegrid.org cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/sft.cern.ch && \
     echo "sft.cern.ch /cvmfs/sft.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-bril.cern.ch  && \
     echo "cms-bril.cern.ch /cvmfs/cms-bril.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-opendata-conddb.cern.ch && \
     echo "cms-opendata-conddb.cern.ch /cvmfs/cms-opendata-conddb.cern.ch cvmfs defaults 0 0" >> /etc/fstab

#RUN mkdir -p /cvmfs/cms.cern.ch

ADD cvmfs/append_to_bashrc.sh /root/.append_to_bashrc.sh
RUN cat /root/.append_to_bashrc.sh >> /root/.bashrc 

ADD go.sh /go.sh
CMD /go.sh
