FROM        debian:sid-slim

MAINTAINER  Olivier Huber <oli.huber@gmail.com>

# Default command on startup.
CMD bash

# Setup packages.
# libtinfo6 is needed by infer 1.1.0 (actually the bundled clang libraries)
# libgfortran5 is for PATH?
# libunwind8 is for DynamoRIO
# jq is to edit compile_commands.json file
# ppl-dev should be installed elsewhere ...
# sqlite is for infer?
# xz-utils is for unpacking the infer archive
RUN GCC_VER=14; LLVM_VER=20; \
    apt-get update --yes && \
    apt-get install -y --no-install-recommends wget gnupg software-properties-common && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/unstable/ llvm-toolchain-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/unstable/ llvm-toolchain-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm.list && \
    apt-get update --yes && \
    apt-get install --yes \
      build-essential \
      bzip2 \
      cmake \
      clang-$LLVM_VER \
      clang-tools-$LLVM_VER \
      cppcheck \
      doxygen \
      flawfinder \
      graphviz \
      g++-$GCC_VER \
      jq \
      libgfortran5 \
      lld-$LLVM_VER \
      libunwind8 \
      openssh-client \
      patch \
      patchelf \
      perl \
      ppl-dev \
      sqlite3 \
      valgrind \
      wget \
      xz-utils \
      \
    && rm -rf /var/lib/apt/lists/*

# Patch ppl to allow clang compilation / analysis
RUN wget -nv http://perso.crans.org/~huber/ppl-clang.patch -O /tmp/ppl-clang.patch && sleep 1 && \
    cd /usr/include/x86_64-linux-gnu && \
    patch -p1 < /tmp/ppl-clang.patch; cd -

# Install infer from a GitHub release
# There is a hack to have the html report generation work (dummy git command)
RUN VERSION=1.2.0; wget -nv -O - "https://github.com/facebook/infer/releases/download/v$VERSION/infer-linux-x86_64-v$VERSION.tar.xz" | tar -C /opt -xJ \
    && for b in $(ls -1 /opt/infer-linux-x86_64-v$VERSION/bin/); do ln -s /opt/infer-linux-x86_64-v$VERSION/bin/$b /usr/local/bin/$b; done && \
    ln -s /bin/true /bin/git

RUN VERSION=11.90.20301; wget -nv -O - https://github.com/DynamoRIO/dynamorio/releases/download/cronbuild-$VERSION/DynamoRIO-Linux-$VERSION.tar.gz | tar -C /opt -xz \
   && for dir in bin64 drmemory/bin64; do for b in $(ls -1 /opt/DynamoRIO-Linux-$VERSION/$dir/); do ln -s /opt/DynamoRIO-Linux-$VERSION/$dir/$b /usr/local/bin/$b; done; done

# install custom infer build
#RUN SERVER=reshop.eu; INFER_NAME=fbinfer-2022.12.12;  wget -nv -O - "https://$SERVER/$INFER_NAME.tar.xz" | tar -C /opt -xJ && \
#    for b in $(ls -1 /opt/${INFER_NAME}/bin/); do ln -s /opt/${INFER_NAME}/bin/$b /usr/local/bin/$b; done && \
#    ln -s /bin/true /bin/git
