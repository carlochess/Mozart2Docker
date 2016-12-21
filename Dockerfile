FROM ubuntu:14.04
MAINTAINER Carlos Roman <carlochess@gmail.com>

RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update 
RUN apt-get install -y libboost-all-dev tk8.5-dev emacs23-nox subversion cmake git python libxml2-dev default-jre make

RUN mkdir externals
WORKDIR /externals
RUN git clone https://github.com/stp/googletest.git gtest
RUN svn co --quiet http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_33/final llvm
WORKDIR /externals/llvm/tools/
RUN svn co --quiet http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_33/final clang
RUN cd ../../.. && mkdir builds && cd builds && mkdir gtest-debug
WORKDIR /builds/gtest-debug
RUN cmake -DCMAKE_BUILD_TYPE=Debug ../../externals/gtest
RUN make -j4
RUN cd .. && mkdir llvm-release
WORKDIR /builds/llvm-release
RUN cmake -DCMAKE_BUILD_TYPE=Release ../../externals/llvm
RUN make -j4

WORKDIR /
RUN git clone --recursive https://github.com/dianacgr/mozart2.git
RUN cd builds && mkdir mozart2-release

WORKDIR /builds/mozart2-release
RUN cmake -DCMAKE_BUILD_TYPE=Release -DGTEST_SRC_DIR=../../externals/gtest -DGTEST_BUILD_DIR=../gtest-debug -DLLVM_SRC_DIR=../../externals/llvm -DLLVM_BUILD_DIR=../llvm-release ../../mozart2
RUN make
RUN make install
RUN rm -rf /externals /builds /mozart2
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -ms /bin/bash mozart
RUN echo mozart:mozart | chpasswd
RUN adduser mozart sudo
ENV PATH="$PATH:/usr/local/bin/oz:"
WORKDIR /home/mozart
ADD helloworld.oz .
RUN chown mozart:mozart helloworld.oz
USER mozart
CMD bash
