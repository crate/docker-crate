## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM ubuntu:16.04
MAINTAINER Crate.IO GmbH office@crate.io

ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN groupadd -r crate && useradd -r -g crate crate

# install crate
ENV CRATE_VERSION 3.0.3
RUN apt-get install -y --no-install-recommends \
        python3 \
        openjdk-8-jre \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-$CRATE_VERSION.tar.gz.asc crate-$CRATE_VERSION.tar.gz \
    && rm -rf "$GNUPGHOME" crate-$CRATE_VERSION.tar.gz.asc \
    && mkdir /crate \
    && tar -xf crate-$CRATE_VERSION.tar.gz -C /crate --strip-components=1 \
    && rm crate-$CRATE_VERSION.tar.gz \
    && ln -s /usr/bin/python3 /usr/bin/python

ENV PATH /crate/bin:$PATH
# Default heap size for Docker, can be overwritten by args
ENV CRATE_HEAP_SIZE 512M

# This healthcheck indicates if a CrateDB node is up and running. It will fail
# if we cannot get any response from the CrateDB (connection refused, timeout
# etc). If any response is received (regardless of http status code) we
# consider the node as running.
HEALTHCHECK --timeout=30s --interval=30s CMD curl --fail --max-time 25 $(hostname):4200

RUN mkdir -p /data/data /data/log

VOLUME /data

ADD config/crate.yml /crate/config/crate.yml
ADD config/log4j2.properties /crate/config/log4j2.properties
COPY entrypoint_3.0.sh /docker-entrypoint.sh

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
# postgres protocol ports: 5432 tcp
EXPOSE 4200 4300 5432

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crate"]
