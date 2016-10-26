FROM alpine:3.4

# add user and group first so their IDs don't change
RUN addgroup crate && adduser -G crate -D -H crate

# su/sudo with proper signaling inside docker
RUN apk add --no-cache su-exec

# install jdk
RUN apk add --no-cache --virtual openjdk8-jre-base

# install crate
ENV CRATE_VERSION 0.56.3
RUN set -xe \
    && apk add --no-cache --virtual .crate-rundeps \
        sigar \
    && apk add --no-cache --virtual .build-deps \
        curl \
        gnupg \
        tar \
    \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz \
    && curl -fSL -O https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz.asc \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 90C23FC6585BC0717F8FBFC37FAAE51A06F6EAEB \
    && gpg --batch --verify crate-$CRATE_VERSION.tar.gz.asc crate-$CRATE_VERSION.tar.gz \
    && rm -r "$GNUPGHOME" crate-$CRATE_VERSION.tar.gz.asc \
    && mkdir /crate \
    && tar -xf crate-$CRATE_VERSION.tar.gz -C /crate --strip-components=1 \
    && chown -R crate:crate /crate \
    && rm /crate/plugins/sigar/lib/libsigar-amd64-linux.so \
    \
    && mkdir /data /config \
    && cp /crate/config/crate.yml /config/crate.yml.dist \
    && cp /crate/config/logging.yml /config/logging.yml.dist \
    && chown -R crate /data /config \
    \
    && apk del .build-deps

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]
EXPOSE 4200 4300 5432

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["crate", "-Des.path.conf", "/config"]
