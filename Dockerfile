## -*- docker-image-name: "docker-crate" -*-
#
# Crate Data Dockerfile
# https://github.com/crate/docker-crate
#

FROM dockerfile/java:openjdk-7-jre

RUN \
  cd /tmp && \
  wget https://cdn.crate.io/downloads/releases/crate-0.41.4.tar.gz && \
  tar xvzf crate-0.41.4.tar.gz && \
  rm -f crate-0.41.4.tar.gz && \
  mv /tmp/crate-0.41.4 /crate


VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml

WORKDIR /data

CMD ["/crate/bin/crate"]

EXPOSE 4200
EXPOSE 4300

