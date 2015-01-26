## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM java:7
MAINTAINER Crate Technology GmbH <office@crate.io>

ENV CRATE_VERSION 0.46.5
RUN mkdir /crate && \
  wget -nv -O - "https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz" \
  | tar -xzC /crate --strip-components=1

RUN mkdir -p /usr/bin
ENV PATH /usr/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

ADD scripts/run.sh /usr/bin/crate
ADD scripts/mesos.in.sh /usr/bin/mesos.in.sh
ADD scripts/weave.in.sh /usr/bin/weave.in.sh

WORKDIR /data

# http
EXPOSE 4200
# transport
EXPOSE 4300

CMD ["crate"]
