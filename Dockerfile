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

ENV CRATE_VERSION 0.54.6
RUN wget -O - "https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz" \
  | tar -xzC / && mv /crate-$CRATE_VERSION /crate

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
