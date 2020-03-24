FROM        debian:sid-slim

MAINTAINER  Olivier Huber <oli.huber@gmail.com>

# Default command on startup.
CMD bash

# Setup packages.
# libtinfo5 and python2.7 is needed by infer 0.17.0
# jq is to edit compile_commands.json file
# ppl-dev should be installed elsewhere ...
RUN apt-get update --yes && apt-get install --yes cmake g++-9 clang-10 clang-tools-10 cppcheck valgrind flawfinder wget ppl-dev doxygen perl-modules libtinfo5 patch python2.7 jq \
    && rm -rf /var/lib/apt/lists/*

# Patch ppl to allow clang compilation / analysis
RUN wget -nv http://perso.crans.org/~huber/ppl-clang.patch -O /tmp/ppl-clang.patch && cd /usr/include/x86_64-linux-gnu && patch -p1 < /tmp/ppl-clang.patch; cd -

# Install infer
# There is a hack to have the html report generation work (dummy git command)
RUN VERSION=0.17.0; wget -nv -O - "https://github.com/facebook/infer/releases/download/v$VERSION/infer-linux64-v$VERSION.tar.xz" | tar -C /opt -xJ \
    && for b in $(ls -1 /opt/infer-linux64-v$VERSION/bin/); do ln -s /opt/infer-linux64-v$VERSION/bin/$b /usr/local/bin/$b; done && \
    ln -s /bin/true /bin/git