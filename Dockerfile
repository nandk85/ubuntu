FROM ubuntu:16.04

RUN apt-get update && apt-get -y upgrade

# Default sh to bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Install the following utilities (required by poky)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential chrpath curl diffstat gcc-multilib gawk git-core libsdl1.2-dev texinfo unzip wget xterm

# Additional host packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-client coreutils libreadline-dev rpcbind nfs-common vim jq

# Additional host packages required by poky/scripts/wic
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bzip2 dosfstools mtools parted syslinux tree
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y regina-rexx lib32z1 lib32stdc++6 autoconf bc flex bison libtool

# Add "repo" tool (used by many Yocto-based projects)
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Install Jfrog cli utility to deploy artifacts
RUN cd /usr/bin; curl -fL https://getcli.jfrog.io | sh
RUN chmod 755 /usr/bin/jfrog

# Disable Host Key verification.
RUN mkdir -p /root/.ssh
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n" > /root/.ssh/config

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
