## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:latest
MAINTAINER Crate.IO GmbH office@crate.io

ENV CDN "https://cdn.crate.io/downloads"
ENV LIB_SIGAR libsigar-amd64-linux.so
ENV CRATE_VERSION 0.54.8

RUN echo 'http://nl.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories

RUN set -ex \
    && apk update \
    && apk add --update-cache openssl ca-certificates libtirpc \
        --virtual .fetch-deps tar wget \
    && wget -nv "$CDN/sigar/$LIB_SIGAR.1.0" -P /usr/local/lib \
    && ln /usr/local/lib/$LIB_SIGAR.1.0 /usr/local/lib/$LIB_SIGAR.1 \
    && runDeps="$(\
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache --virtual .libsigar-rundeps $runDeps

RUN mkdir /crate \
    && wget -nv -O - "$CDN/releases/crate-$CRATE_VERSION.tar.gz" \
        | tar -xzC /crate --strip-components=1 \
    && apk add --update-cache openjdk8-jre-base python3 \
    && apk del .fetch-deps \
    && rm -rf /var/cache/apk/*

RUN ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/local/lib/$LIB_SIGAR.1 /crate/lib/sigar/$LIB_SIGAR

RUN addgroup crate && adduser -G crate -H crate -D && chown -R crate /crate
ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
EXPOSE 4200 4300

CMD ["crate"]
