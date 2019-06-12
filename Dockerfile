FROM centos:6
MAINTAINER Alexx Perloff "Alexx.Perloff@Colorado.edu"

RUN yum update -y
ADD cvmfs/cernvm.repo /etc/yum.repos.d/cernvm.repo
RUN yum install emacs openssh-server nano cvmfs man freetype openssl098e libXpm libXext wget git  tcsh zsh tcl  perl-ExtUtils-Embed perl-libwww-perl  compat-libstdc++-33  libXmu  libXpm  zip e2fsprogs krb5-devel krb5-workstation  strace libXft xdm ImageMagick ImageMagick-devel mesa-libGL mesa-libGLU glx-utils -y
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
# Bad security, add a user and sudo instead!
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
# Configuring xdm to allow connections from any IP address and ssh to allow X11 Forwarding. 
RUN sed -i 's/DisplayManager.requestPort/!DisplayManager.requestPort/g' /etc/X11/xdm/xdm-config && \
    sed -i '/#any host/c\*' /etc/X11/xdm/Xaccess && \
    ln -s /usr/bin/Xorg /usr/bin/X && \
    echo X11Forwarding yes >> /etc/ssh/ssh_config
# Install fonts for X11
RUN wget https://www.itzgeek.com/msttcore-fonts-2.0-3.noarch.rpm && \
    rpm -Uvh msttcore-fonts-2.0-3.noarch.rpm && \
    rm msttcore-fonts-2.0-3.noarch.rpm

#Change the password 'cms-docker' to something unique
RUN echo 'root:cms-docker' |chpasswd

ADD cvmfs/default.local /etc/cvmfs/default.local
ADD cvmfs/run.sh /root/run.sh
ADD cvmfs/append_to_bashrc.sh /root/.append_to_bashrc.sh
RUN cat /root/.append_to_bashrc.sh >> /root/.bashrc && \
     mkdir .globus && \
     chmod 0700 .globus && \
     mkdir /cvmfs/cms.cern.ch ; #mkdir /cvmfs/cms-condb.cern.ch && \
     echo "cms.cern.ch /cvmfs/cms.cern.ch cvmfs defaults 0 0" >> /etc/fstab && \
     mkdir /cvmfs/cms-ib.cern.ch ;  && \
     echo "cms-ib.cern.ch /cvmfs/cms-ib.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/oasis.opensciencegrid.org ;  && \
     echo "oasis.opensciencegrid.org /cvmfs/oasis.opensciencegrid.org cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-lpc.opensciencegrid.org ;  && \
     echo "cms-lpc.opensciencegrid.org /cvmfs/cms-lpc.opensciencegrid.org cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/sft.cern.ch ;  && \
     echo "sft.cern.ch /cvmfs/sft.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-bril.cern.ch ;  && \
     echo "cms-bril.cern.ch /cvmfs/cms-bril.cern.ch cvmfs defaults 0 0" >> /etc/fstab  && \
     mkdir /cvmfs/cms-opendata-conddb.cern.ch ;  && \
     echo "cms-opendata-conddb.cern.ch /cvmfs/cms-opendata-conddb.cern.ch cvmfs defaults 0 0" >> /etc/fstab

EXPOSE 22
CMD /root/run.sh
