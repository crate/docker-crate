## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:3.3
MAINTAINER Crate.IO GmbH office@crate.io

RUN addgroup crate && adduser -G crate -H crate -D

RUN echo 'http://dl-5.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories

# install crate
ENV CRATE_VERSION 0.54.8
RUN    apk add --no-cache --virtual .crate-rundeps openjdk8-jre-base python3 openssl sigar \
    && apk add --no-cache --virtual .build-deps curl gnupg tar \
    && curl -fSLsO https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
    && curl -fSLsO https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 7faae51a06f6eaeb \
    && gpg --batch --verify crate-$CRATE_VERSION.tar.gz.asc crate-$CRATE_VERSION.tar.gz \
    && rm -rf "$GNUPGHOME" crate-$CRATE_VERSION.tar.gz.asc \
    && mkdir /crate \
    && tar -xf crate-$CRATE_VERSION.tar.gz -C /crate --strip-components=1 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && cp -f /usr/lib/libsigar-amd64-linux.so /crate/lib/sigar/ \
    && chown -R crate /crate \
    && apk del .build-deps

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml   /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /data

EXPOSE 4200 4300

CMD ["crate"]
