## -*- docker-image-name: "docker-crate" -*-
#
# Crate Data Dockerfile
# https://github.com/crate/docker-crate
#

FROM java:7

ENV CRATE_VERSION 0.45.2
RUN mkdir /crate && \
  wget -nv -O - "https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz" \
  | tar -xzC /crate --strip-components=1

ENV PATH /crate/bin:$PATH

VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml

WORKDIR /data

CMD ["crate"]

EXPOSE 4200
EXPOSE 4300
