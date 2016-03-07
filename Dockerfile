## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM alpine:latest
MAINTAINER Crate Technology GmbH <office@crate.io>

RUN echo 'http://nl.alpinelinux.org/alpine/latest-stable/community' >> /etc/apk/repositories
RUN apk update && \
    apk add openjdk8-jre-base && \
    apk add openssl && \
    apk add python3 && \
    rm -rf /var/cache/apk/* && \
    ln -s /usr/bin/python3 /usr/bin/python


# tmp folder on Crate CDN
ENV CDN_URL "https://cdn.crate.io/downloads/releases/tmp"
# Crate version
ENV CRATE_VERSION "0.55.0-201603070301-07b8045"
ENV CRATE_URL "${CDN_URL}/crate-${CRATE_VERSION}.tar.gz"
# Commoncrawl Plugin version
ENV PLUGIN_VERSION "0.55.0-SNAPSHOT-e9f39af"
ENV PLUGIN_URL "${CDN_URL}/crate-commoncrawl-${PLUGIN_VERSION}.jar"

# download Crate
RUN wget -O - ${CRATE_URL} | tar -xzC / && \
    mv /crate-* /crate
# remove unused plugins and download commoncrawl plugin
RUN rm -rf /crate/plugins && \
    mkdir -pv /crate/plugins/commoncrawl && \
    wget -O /crate/plugins/commoncrawl/crate-commoncrawl-${PLUGIN_VERSION}.jar ${PLUGIN_URL}

# add executable to path
ENV PATH /crate/bin:$PATH

# expose multiple mount points
VOLUME /data1 /data2 /data3 /data4 /data5

# add basic configuration
ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /crate

# http: 4200 tcp
# transport: 4300 tcp
EXPOSE 4200 4300

CMD ["crate"]
