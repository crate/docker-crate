## -*- docker-image-name: "crate/libsigar" -*-
#
# Crate/libsigar Dockerfile
# https://github.com/crate/docker-crate/sigar
#

FROM alpine:latest
MAINTAINER Crate.IO GmbH office@crate.io

ENV ANT_VERSION 1.9.7

RUN echo 'http://nl.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories

RUN set -ex \
    && apk update \
    && apk add --update-cache --virtual .build-deps \
          git gcc libc-dev make cmake libtirpc-dev pax-utils \
          curl openjdk8 gnupg perl \
    && mkdir -p /opt \
    && cd /opt \
    && curl -fSL https://www.apache.org/dist/ant/KEYS -o KEYS \
    && curl -fSL -O https://www.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.asc \
    && curl -fSL -O http://apache.uib.no//ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && gpg --import KEYS \
    && gpg --verify apache-ant-${ANT_VERSION}-bin.tar.gz.asc \
    && tar -zxf apache-ant-${ANT_VERSION}-bin.tar.gz \
    && ln -s /opt/apache-ant-${ANT_VERSION}/bin/ant /usr/bin/ant

ENV SIGAR /sigar/
ENV OUT /out/

RUN mkdir $SIGAR
ADD sigar_build.sh $SIGAR
ADD sigar_build.patch $SIGAR

RUN mkdir $OUT
VOLUME $OUT

WORKDIR $SIGAR

CMD ["/bin/sh", "sigar_build.sh"]
