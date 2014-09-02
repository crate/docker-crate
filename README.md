# Crate Data Dockerfile

This repository contains **Dockerfile** of [Crate Data][3] for [Docker][1]'s [automated build][2]
published to the public [Docker Hub Registry][4].


## Base Docker Image

- [dockerfile/java:openjdk-7-jre][5]

## Installation

1. Install [Docker][1]

2. Download automated build from public [Docker Hub Registry][2]

        docker pull crate/crate

   alternatively you can build an image from `Dockerfile`:

        docker build -t="crate/crate" github.com/crate/docker-crate

## Usage

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate

## Attach persistent data directory

    docker run -d -p 4200:4200 -p 4300:4300 -v <data-dir>:/data crate/crate

## Use custom Crate configuration

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate -Des.config=/path/to/crate.yml

Any configuration settings may be specified upon startup using the `-D` option prefix.
For example, configuring the cluster name by using system properties will work this way::

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate /crate/bin/crate -Des.cluster.name=cluster

For further configuration options please refer to the [Configuration][6] section of the online documentation.

## Multicast

Crate uses multicast for node discovery by default. However, Docker does only support multicast on the same
host. This means that nodes that are started on the same host will discover each other automatically,
but nodes that are started on different hosts need unicast enabled.

You can enable unicast in your custom ``crate.yml``. See also: [Using Crate Data in a Multi Node Setup][7].


[1]: https://www.docker.com
[2]: https://registry.hub.docker.com/u/crate/crate/
[3]: https://crate.io
[4]: https://registry.hub.docker.com/
[5]: http://dockerfile.github.io/#/java
[6]: https://crate.io/docs/stable/configuration.html
[7]: https://crate.io/blog/using-crate-in-multinode-setup/

