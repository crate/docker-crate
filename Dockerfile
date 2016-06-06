## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:3.3
MAINTAINER Crate.IO GmbH office@crate.io

ENV ANT_VERSION 1.9.7
ENV SIGAR_VERSION 1.6.4

RUN addgroup crate && adduser -G crate -H crate -D

ADD sigar/sigar_build.patch /var/tmp/

# build sigar library
RUN set -ex \
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
    && BUILD_DIR=$(mktemp -d) \
    && cd $BUILD_DIR \
    && curl -fSL https://www.apache.org/dist/ant/KEYS -o KEYS \
    && curl -fSL -O https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz.asc \
    && curl -fSL -O https://www-us.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --import KEYS \
    && gpg --batch --verify apache-ant-$ANT_VERSION-bin.tar.gz.asc apache-ant-$ANT_VERSION-bin.tar.gz \
    && rm -r "$GNUPGHOME" apache-ant-$ANT_VERSION-bin.tar.gz.asc \
    && tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz \
    && git clone https://github.com/hyperic/sigar.git --single-branch --branch sigar-$SIGAR_VERSION sigar \
    && cd sigar \
    && git apply /var/tmp/sigar_build.patch \
    && cd bindings/java \
    && $BUILD_DIR/apache-ant-$ANT_VERSION/bin/ant \
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
    && rm -rf $BUILD_DIR

# install crate
ENV CRATE_VERSION 0.55.0
RUN apk add --no-cache --virtual .crate-rundeps openjdk8-jre-base python3 openssl \
    && apk add --no-cache --virtual .build-deps curl gnupg tar \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-$CRATE_VERSION.tar.gz.asc crate-$CRATE_VERSION.tar.gz \
    && rm -r "$GNUPGHOME" crate-$CRATE_VERSION.tar.gz.asc \
    && mkdir /crate \
    && tar -xf crate-$CRATE_VERSION.tar.gz -C /crate --strip-components=1 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && cp -f /usr/local/lib/*.so /crate/plugins/sigar/lib/ \
    && chown -R crate /crate \
    && apk del .build-deps

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
EXPOSE 4200 4300

CMD ["crate"]
