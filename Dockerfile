FROM m0elnx/ubuntu-32bit

RUN apt-get update

RUN apt-get -y install fakeroot xmlto vim bison flex texinfo automake bc 
RUN apt-get -y install autoconf gawk libtool build-essential cvs libncurses5-dev tree gettext zlib1g-dev 
RUN apt-get -y install intltool git-core cadaver lftp ncftp squashfs-tools subversion minicom curl gperf 
RUN apt-get -y install libglib2.0-dev cramfsprogs curl wine diffstat texi2html chrpath g++-multilib gcc-multilib 
RUN apt-get -y install gperf flex xutils-dev zip

RUN apt-get -y purge software-properties-common && apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/* 

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

USER build
WORKDIR /home/build
CMD "/bin/bash"
