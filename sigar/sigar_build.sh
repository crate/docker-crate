#!/bin/sh

SIGAR_VERSION=1.6.4
SOVERSION=1.0

# get sigar source and patch the sigar build process
git clone https://github.com/hyperic/sigar.git sigar
cd sigar

git checkout "sigar-${SIGAR_VERSION}"
git apply ../sigar_build.patch

cd bindings/java
ant

# move the sigar shared library to the output folder
for so in $(find sigar-bin/lib/ -name "*.so"); do
    mv $so /out/`echo $so | cut -d/ -f3 | sed "s/$/.${SOVERSION}/"`
done
