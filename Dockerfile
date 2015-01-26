## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#

FROM java:7

ENV CRATE_VERSION 0.45.6
RUN mkdir /crate && \
  wget -nv -O - "https://cdn.crate.io/downloads/releases/crate-$CRATE_VERSION.tar.gz" \
  | tar -xzC /crate --strip-components=1

ENV PATH /crate/bin:$PATH
VOLUME ["/data"]

ADD config/crate.yml /crate/config/crate.yml
ADD scripts/run.sh /crate/bin/run.sh

WORKDIR /data

# http
EXPOSE 4200
# transport
EXPOSE 4300

CMD ["run.sh"]
