#
# To use, run:
#   docker build -t 5gen-c .
#   docker run -it 5gen-c /bin/bash
#

FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
# RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y ppa:hvr/ghc
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install gcc g++
# RUN apt-get -y install gcc-6 g++-6
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
RUN apt-get -y install autoconf libtool make flex bison
RUN apt-get -y install libgmp-dev libmpfr-dev libssl-dev libflint-dev
RUN apt-get -y install cabal-install ghc
RUN apt-get -y install python perl

RUN apt-add-repository -y ppa:aims/sagemath
RUN apt-get -y update
# RUN apt-get -y install sagemath-upstream-binary

WORKDIR /inst
RUN git clone https://github.com/5GenCrypto/5gen-c.git

WORKDIR /inst/5gen-c
CMD git pull origin master
