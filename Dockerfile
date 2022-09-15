## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM centos:7

# Install prerequisites and package updates and clean up repository indexes again
RUN yum install -y yum-utils deltarpm \
    && yum makecache \
    && yum upgrade -y \
    && yum install -y python3 openssl \
    && pip3 install --upgrade pip \
    && yum clean all \
    && rm -rf /var/cache/yum

# Install CrateDB
RUN groupadd crate \
    && useradd -u 1000 -g crate -d /crate crate \
    && export PLATFORM="$( \
        case $(uname --m) in \
            x86_64)  echo x64_linux ;; \
            aarch64) echo aarch64_linux ;; \
        esac)" \
    && export CRATE_URL=https://cdn.crate.io/downloads/releases/cratedb/${PLATFORM}/crate-4.8.4.tar.gz \
    && curl -fSL -O ${CRATE_URL} \
    && curl -fSL -O ${CRATE_URL}.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-4.8.4.tar.gz.asc crate-4.8.4.tar.gz \
    && rm -rf "$GNUPGHOME" crate-4.8.4.tar.gz.asc \
    && tar -xf crate-4.8.4.tar.gz -C /crate --strip-components=1 \
    && rm crate-4.8.4.tar.gz

# Install crash
RUN curl -fSL -O https://cdn.crate.io/downloads/releases/crash_standalone_0.28.0 \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crash_standalone_0.28.0.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crash_standalone_0.28.0.asc crash_standalone_0.28.0 \
    && rm -rf "$GNUPGHOME" crash_standalone_0.28.0.asc \
    && mv crash_standalone_0.28.0 /usr/local/bin/crash \
    && chmod +x /usr/local/bin/crash

ENV PATH /crate/bin:$PATH
# Default heap size for Docker, can be overwritten by args
ENV CRATE_HEAP_SIZE 512M

RUN mkdir -p /data/data /data/log

VOLUME /data

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
# postgres protocol ports: 5432 tcp
EXPOSE 4200 4300 5432

# These COPY commands have been moved before the last one due to the following issues:
# https://github.com/moby/moby/issues/37965#issuecomment-448926448
# https://github.com/moby/moby/issues/38866
COPY --chown=1000:0 config/crate.yml /crate/config/crate.yml
COPY --chown=1000:0 config/log4j2.properties /crate/config/log4j2.properties

LABEL maintainer="Crate.io <office@crate.io>" \
    org.opencontainers.image.created="2022-09-15T10:52:50.199012" \
    org.opencontainers.image.title="crate" \
    org.opencontainers.image.description="CrateDB is a distributed SQL database that handles massive amounts of machine data in real-time." \
    org.opencontainers.image.url="https://crate.io/products/cratedb/" \
    org.opencontainers.image.source="https://github.com/crate/docker-crate" \
    org.opencontainers.image.vendor="Crate.io" \
    org.opencontainers.image.version="4.8.4"

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crate"]
