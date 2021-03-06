FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade

# Install the following utilities (required by poky)
RUN apt-get install -y build-essential chrpath curl diffstat gcc-multilib gawk git-core libsdl1.2-dev texinfo unzip wget xterm

# Additional host packages
RUN apt-get install -y openssh-client coreutils libreadline-dev rpcbind nfs-common vim

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y bzip2 dosfstools mtools parted syslinux tree

RUN  apt-get -y install regina-rexx lib32z1 lib32stdc++6 autoconf bc flex bison libtool

RUN echo "10.45.16.232 gitlab.chs.cisco.com" >> /etc/hosts

# Add "repo" tool (used by many Yocto-based projects)
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Install Jfrog cli utility to deploy artifacts
RUN cd /usr/bin; curl -fL https://getcli.jfrog.io | sh
RUN chmod 755 /usr/bin/jfrog

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Default sh to bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Create toolchain directory required by ecm build for docsis gateway 
RUN mkdir -p /opt/toolchains
RUN chown -R build:build /opt

# Disable Host Key verification.
RUN mkdir -p /home/build/.ssh
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/build/.ssh/config
RUN chown -R build:build /home/build/.ssh

USER build
WORKDIR /home/build
CMD "/bin/bash"
