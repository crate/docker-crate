# Supported Tags

- `latest`
- [`0.41.4`](https://github.com/crate/docker-crate/releases/tag/0.41.4)
- [`0.42.1`](https://github.com/crate/docker-crate/releases/tag/0.42.1)
- [`0.42.2`](https://github.com/crate/docker-crate/releases/tag/0.42.2)
- [`0.42.3`](https://github.com/crate/docker-crate/releases/tag/0.42.3)
- [`0.43.1`](https://github.com/crate/docker-crate/releases/tag/0.43.1)

# What is Crate?

Crate is an Elastic SQL Data Store. Distributed by design, Crate makes
centralized database servers obsolete. Realtime non-blocking SQL engine with
full blown search. Highly available, massively scalable yet simple to use.

    [Crate][3]

# Crate Data Dockerfile

This repository contains **Dockerfile** of [Crate Data][3] for [Docker][1]'s [automated build][2]
published to the public [Docker Hub Registry][4].


## Base Docker Image

- [java:][5]

## Installation

1. Install [Docker][1]

2. Download latest automated build from public [Docker Hub Registry][2]

        docker pull crate/crate:latest

   alternatively you can build an image from `Dockerfile`:

        docker build -t="crate/crate" github.com/crate/docker-crate

## How to use this image

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate:latest

### Attach persistent data directory

    docker run -d -p 4200:4200 -p 4300:4300 -v <data-dir>:/data crate/crate

### Use custom Crate configuration

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate -Des.config=/path/to/crate.yml

Any configuration settings may be specified upon startup using the `-D` option prefix.
For example, configuring the cluster name by using system properties will work this way::

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate /crate/bin/crate -Des.cluster.name=cluster

For further configuration options please refer to the [Configuration][6] section of the online documentation.

### Environment

To set environment variables for Crate Data you need to use the ``--env`` option when starting
the docker image.

For example, setting the heap size:

    docker run -d -p 4200:4200 -p 4300:4300 --env CRATE_HEAP_SIZE=32g crate/crate

## Multicast

Crate uses multicast for node discovery by default. However, Docker does only support multicast on the same
host. This means that nodes that are started on the same host will discover each other automatically,
but nodes that are started on different hosts need unicast enabled.

You can enable unicast in your custom ``crate.yml``. See also: [Using Crate Data in a Multi Node Setup][7].


# License

View [license information][8] for the software contained in this image.


# User Feedback

## Issues

If you have any problems with, or questions about this image,
please contact us through a [GitHub issue][9].

If you have any questions or suggestions we would be very happy to help you.
So, feel free to swing by our IRC channel `#crate` on [Freenode][10].

For further information and official contact please visit [https://crate.io][3].

## Contributing

You are very welcome to contribute features or fixes! Before we can accept any pull requests to Crate Data
we need you to agree to our [CLA][11]. For further information please refer to [CONTRIBUTING.rst][12].



[1]: https://www.docker.com
[2]: https://registry.hub.docker.com/u/crate/crate/
[3]: https://crate.io
[4]: https://registry.hub.docker.com/
[5]: https://registry.hub.docker.com/_/java/
[6]: https://crate.io/docs/stable/configuration.html
[7]: https://crate.io/blog/using-crate-in-multinode-setup/
[8]: https://github.com/crate/crate/blob/master/LICENSE.txt
[9]: https://github.com/crate/docker-crate/issues
[10]: http://freenode.net
[11]: https://crate.io/community/contribute/
[12]: https://github.com/crate/crate/blob/master/CONTRIBUTING.rst
