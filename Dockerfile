## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM centos:7.5.1804
MAINTAINER Crate.IO GmbH office@crate.io

RUN groupadd crate && useradd -u 1000 -g crate -d /crate crate

COPY docker-entrypoint.sh /

# install crate
RUN yum install -y yum-utils https://centos7.iuscommunity.org/ius-release.rpm \
    && yum makecache \
    && yum install -y python36u openssl java-1.8.0-openjdk \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-3.1.1.tar.gz \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-3.1.1.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-3.1.1.tar.gz.asc crate-3.1.1.tar.gz \
    && rm -rf "$GNUPGHOME" crate-3.1.1.tar.gz.asc \
    && tar -xf crate-3.1.1.tar.gz -C /crate --strip-components=1 \
    && rm crate-3.1.1.tar.gz \
    && ln -sf /usr/bin/python3.6 /usr/bin/python3

COPY --chown=1000:0 config/crate.yml /crate/config/crate.yml
COPY --chown=1000:0 config/log4j2.properties /crate/config/log4j2.properties

# install crash
RUN curl -fSL -O https://cdn.crate.io/downloads/releases/crash_standalone_0.24.2\
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crash_standalone_0.24.2.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crash_standalone_0.24.2.asc crash_standalone_0.24.2 \
    && rm -rf "$GNUPGHOME" crash_standalone_0.24.2.asc \
    && mv crash_standalone_0.24.2 /usr/local/bin/crash \
    && chmod +x /usr/local/bin/crash

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

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
# postgres protocol ports: 5432 tcp
EXPOSE 4200 4300 5432

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="2018-11-19T13:29:38.321049833+00:00" \
    org.label-schema.name="crate" \
    org.label-schema.description="CrateDB is a distributed SQL database handles massive amounts of machine data in real-time." \
    org.label-schema.url="https://crate.io/products/cratedb/" \
    org.label-schema.vcs-url="https://github.com/crate/docker-crate" \
    org.label-schema.vendor="Crate.io" \
    org.label-schema.version="3.1.1"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crate"]
