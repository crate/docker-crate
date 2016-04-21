#!/bin/sh

SIGAR_VERSION=1.6.4

# get sigar source and patch the sigar build process
/usr/bin/git clone --branch sigar-${SIGAR_VERSION} https://github.com/hyperic/sigar.git
/usr/bin/git clone --branch r/build-sig https://github.com/crate/docker-crate.git
cd sigar
/usr/bin/git apply ../docker-crate/sigar/sigar_build.patch
cd bindings/java

# build sigar libs
/usr/bin/ant

# move sigar libs to the output directory
mv -f sigar-bin/lib/sigar.jar /out/sigar-${SIGAR_VERSION}.jar
mv -f sigar-bin/lib/libsigar*.so /out
