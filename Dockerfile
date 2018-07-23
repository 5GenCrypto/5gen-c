#
# To use, run:
#   docker build -t 5gen-c .
#   docker run -it 5gen-c /bin/bash
#

FROM ubuntu:latest

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:hvr/ghc
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install gcc g++
RUN apt-get -y install autoconf libtool make flex bison
RUN apt-get -y install libgmp-dev libmpfr-dev libssl-dev libflint-dev
RUN apt-get -y install python perl
RUN apt-get -y install wget bsdtar
RUN apt-get -y install z3
RUN apt-get -y install cryptol 

#
# Install GHC
#

RUN wget -q https://haskell.org/platform/download/8.4.3/haskell-platform-8.4.3-unknown-posix--core-x86_64.tar.gz
RUN tar xf haskell-platform-8.4.3-unknown-posix--core-x86_64.tar.gz
RUN ./install-haskell-platform.sh

#
# Install yosys
#

WORKDIR /inst
ENV DEBIAN_FRONTEND "noninteractive apt-get autoremove"
RUN apt-get -y install yosys

#
# Install SAW
#

# We need to copy CryptolTC.z3 from the cryptol source repo for saw to work

WORKDIR /inst
RUN git clone https://github.com/GaloisInc/cryptol.git
RUN mkdir /root/.cryptol
RUN cp cryptol/lib/CryptolTC.z3 /root/.cryptol

WORKDIR /inst
RUN wget -q https://github.com/GaloisInc/saw-script/releases/download/v0.2/saw-0.2-2016-04-12-Ubuntu14.04-64.tar.gz
RUN tar xf saw-0.2-2016-04-12-Ubuntu14.04-64.tar.gz
ENV PATH "/inst/saw-0.2-2016-04-12-Ubuntu14.04-64/bin:$PATH"

#
# Install Sage
#

WORKDIR /inst
RUN apt-get -y install lbzip2 gfortran
RUN wget -q http://mirrors.mit.edu/sage/linux/64bit/sage-7.6-Ubuntu_16.04-x86_64.tar.bz2
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
