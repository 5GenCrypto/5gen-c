#
# To use, run:
#   docker build -t 5gen-c .
#   docker run -it 5gen-c /bin/bash
#

FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:hvr/ghc
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install gcc g++
RUN apt-get -y install autoconf libtool make flex bison
RUN apt-get -y install libgmp-dev libmpfr-dev libssl-dev libflint-dev
RUN apt-get -y install cabal-install ghc
RUN apt-get -y install python perl
RUN apt-get -y install wget
RUN apt-get -y install bsdtar

#
# Install Z3
#

WORKDIR /inst
RUN wget https://github.com/Z3Prover/z3/archive/z3-4.5.0.tar.gz
RUN tar xf z3-4.5.0.tar.gz
WORKDIR /inst/z3-z3-4.5.0
RUN ./configure
WORKDIR /inst/z3-z3-4.5.0/build
RUN make -j8
RUN make install

#
# Install Cryptol
#

WORKDIR /inst
RUN wget https://github.com/GaloisInc/cryptol/releases/download/2.4.0/cryptol-2.4.0-Ubuntu1404-64.tar.gz
RUN tar xf cryptol-2.4.0-Ubuntu1404-64.tar.gz
ENV PATH "/inst/cryptol-2.4.0-Ubuntu14.04-64/bin:$PATH"

#
# Install SAW
#

# We need to copy CryptolTC.z3 from the cryptol source repo for saw to work

WORKDIR /inst
RUN git clone https://github.com/GaloisInc/cryptol.git
RUN mkdir /root/.cryptol
RUN cp cryptol/lib/CryptolTC.z3 /root/.cryptol

WORKDIR /inst
RUN wget https://github.com/GaloisInc/saw-script/releases/download/v0.2/saw-0.2-2016-04-12-Ubuntu14.04-64.tar.gz
RUN tar xf saw-0.2-2016-04-12-Ubuntu14.04-64.tar.gz
ENV PATH "/inst/saw-0.2-2016-04-12-Ubuntu14.04-64/bin:$PATH"

#
# Install ABC
#

WORKDIR /inst
RUN apt-get -y install mercurial cmake libreadline-dev
RUN hg clone https://bitbucket.org/alanmi/abc
WORKDIR /inst/abc
RUN cmake .
RUN make -j8
ENV PATH "/inst/abc:$PATH"

#
# Install yosys
#

WORKDIR /inst
RUN apt-get -y install yosys

#
# Install Sage
#

WORKDIR /inst
RUN apt-get -y install lbzip2 gfortran
RUN wget http://mirrors.mit.edu/sage/linux/64bit/sage-7.6-Ubuntu_16.04-x86_64.tar.bz2
RUN bsdtar xvf sage-7.6-Ubuntu_16.04-x86_64.tar.bz2
ENV PATH "/inst/SageMath:$PATH"

#
# Get 5gen-c repository
#

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/5gen-c.git

WORKDIR /inst/5gen-c
RUN git pull origin master
RUN ./build.sh
