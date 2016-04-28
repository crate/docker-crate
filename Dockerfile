## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:3.3
MAINTAINER Crate.IO GmbH office@crate.io

ENV ANT_VERSION 1.9.7
ENV CRATE_VERSION 0.54.8

RUN addgroup crate && adduser -G crate -H crate -D

ADD sigar/sigar_build.patch /var/tmp/

# build sigar library
RUN set -ex \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        tar \
        git \
        gcc \
        cmake \
        libc-dev \
        libtirpc-dev \
        pax-utils \
        openjdk8 \
        gnupg \
        perl \
    && mkdir /build \
    && cd /build \
    && curl -fSL https://www.apache.org/dist/ant/KEYS -o KEYS \
    && curl -fSL -O https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz.asc \
    && curl -fSL -O http://apache.uib.no//ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz \
    && gpg --import KEYS \
    && gpg --verify apache-ant-$ANT_VERSION-bin.tar.gz.asc \
    && tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz \
    && git clone https://github.com/hyperic/sigar.git --single-branch --branch sigar-1.6.4 sigar \
    && cd sigar \
    && git apply /var/tmp/sigar_build.patch \
    && cd bindings/java \
    && /build/apache-ant-$ANT_VERSION/bin/ant \
    && find build -name '*.so*' | xargs install -t /usr/local/lib \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .libsigar-rundeps $runDeps \
    && apk del .build-deps \
    && rm -rf /build

# install crate
RUN apk add --no-cache --virtual .crate-rundeps openjdk8-jre-base python3 openssl \
    && wget -O - https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
        | tar -xzC / && mv /crate-$CRATE_VERSION /crate \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && cp -f /usr/local/lib/*.so /crate/lib/sigar/ \
    && chown -R crate /crate

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
EXPOSE 4200 4300

CMD ["crate"]
