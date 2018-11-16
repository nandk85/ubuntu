FROM ubuntu:12.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

# Install the following utilities (required by poky)
RUN apt-get install -y build-essential chrpath curl diffstat gcc-multilib gawk texinfo unzip wget

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y bzip2 dosfstools mtools parted syslinux tree lzma pkg-config zlib1g-dev php5-dev tcllib

RUN echo "10.45.16.232 gitlab.chs.cisco.com" >> /etc/hosts

# Additional host packages
RUN apt-get install -y openssh-client coreutils libreadline-dev rpcbind nfs-common vim xutils-dev xmlto intltool

RUN apt-get -y install regina-rexx lib32z1 autoconf bc flex bison sharutils ssh sudo realpath libmpc-dev quilt
RUN apt-get -y install libtool lib32ncurses5-dev gettext g++-multilib doxygen ccache libiconv-hook1 libiconv-hook-dev

# All Python packages
RUN cd /tmp; curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN cd /tmp; python get-pip.py

RUN pip install requests 

RUN cd /usr/lib/x86_64-linux-gnu; ln -s libmpc.so.2.0.0 libmpc.so.3

# Build and install patch 2.5
RUN cd /tmp; wget ftp://ftp.gnu.org/gnu/patch/patch-2.5.tar.gz
RUN cd /tmp; tar -xzf patch-2.5.tar.gz
RUN cd /tmp/patch-2.5; ./configure --prefix=/usr; make; make install
RUN cd /; rm -rf /tmp/patch-2.5

# Build and install jq
RUN cd /tmp; wget http://security.ubuntu.com/ubuntu/pool/universe/j/jq/jq_1.2-8~ubuntu12.04.1_amd64.deb
RUN cd /tmp; DEBIAN_FRONTEND=noninteractive dpkg -i jq_1.2-8~ubuntu12.04.1_amd64.deb

# Installing latest version of git to support all new features and formats
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update
RUN apt-get --allow-unauthenticated install git git-core -y

RUN mkdir -p /root/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n" > /root/.ssh/config
RUN chown -R root:root /root/.ssh

RUN apt-get -y purge software-properties-common && apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/*

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN mkdir -p /home/build/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n" > /home/build/.ssh/config
RUN chown -R build:build /home/build/.ssh

# Default sh to bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER build
WORKDIR /home/build
CMD "/bin/bash"
