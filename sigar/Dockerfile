## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:latest
MAINTAINER Crate Technology GmbH <office@crate.io>

ENV ANT_VERSION=1.9.7

RUN echo 'http://nl.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories
RUN set -ex \
    && apk update \
    && apk add -u --no-cache --virtual .build-deps \
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

ENV SIGAR_DIR /sigar
ENV OUT_DIR /out

RUN mkdir $OUT_DIR
VOLUME $OUT_DIR

WORKDIR $SIGAR_DIR

COPY sigar_build.sh $SIGAR_DIR
COPY sigar_build.patch $SIGAR_DIR

CMD ["/bin/sh", "sigar_build.sh"]
