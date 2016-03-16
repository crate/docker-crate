## -*- docker-image-name: "docker-crate" -*-
#
# Crate Dockerfile
# https://github.com/crate/docker-crate
#
FROM java:8-jre
MAINTAINER Crate Technology GmbH <office@crate.io>

RUN apt-get update && \
    apt-get install -y python3 && \
    rm -rf /var/lib/apt && \
    ln -s /usr/bin/python3 /usr/bin/python

# tmp folder on Crate CDN
ENV CDN_URL "https://cdn.crate.io/downloads/releases/tmp"
# Crate version
ENV CRATE_VERSION "0.55.0-201603160301-76d45ee"
ENV CRATE_URL "${CDN_URL}/crate-${CRATE_VERSION}.tar.gz"
# Commoncrawl Plugin version
ENV PLUGIN_VERSION "1.1-SNAPSHOT"
ENV PLUGIN_URL "${CDN_URL}/crate-commoncrawl-${PLUGIN_VERSION}.jar"

RUN mkdir /crate && \
  wget -nv -O - ${CRATE_URL} \
  | tar -xzC /crate --strip-components=1 && \
  mkdir -pv /crate/plugins/commoncrawl && \
  wget -O /crate/plugins/commoncrawl/crate-commoncrawl-${PLUGIN_VERSION}.jar ${PLUGIN_URL}


ENV PATH /crate/bin:$PATH

# expose multiple mount points
VOLUME /data1 /data2 /data3 /data4 /data5

ADD config/crate.yml /crate/config/crate.yml
ADD config/logging.yml /crate/config/logging.yml

WORKDIR /crate

# http: 4200 tcp
# transport: 4300 tcp
EXPOSE 4200 4300

CMD ["crate"]
