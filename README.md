# What is Crate?

Crate is _the_ distributed database for containerized environments, such as Docker.
Based on the familiar SQL syntax, Crate combines high availability, resiliency, and scalability
in a distributed design that allows you to query mountains of data in realtime, not batches.

We solve your data scaling problems and make administration a breeze.

**Crate.IO - Put your data to work. Simply.**

[http://crate.io][3]


# Crate Dockerfile

This repository contains **Dockerfile** of [Crate][3] for [Docker][1]'s [automated build][2]
published to the public [Docker Hub Registry][4].


## Base Docker Image

- [alpine:latest][5]

## Installation

1. Install [Docker][1]

2. Download latest automated build from public [Docker Hub Registry][2]

    docker pull crate/crate:latest

Alternatively you can build an image from `Dockerfile`:

    docker build -t="crate/crate" github.com/crate/docker-crate

## How to use this image

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate:latest

### Attach persistent data directory

    docker run -d -p 4200:4200 -p 4300:4300 -v <data-dir>:/data crate/crate

### Use custom Crate configuration

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate crate -Des.config=/path/to/crate.yml

Any configuration settings may be specified upon startup using the `-D` option prefix.
For example, configuring the cluster name by using system properties will work this way::

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate crate -Des.cluster.name=cluster

For further configuration options please refer to the [Configuration][6] section of the online documentation.

### Environment

To set environment variables for Crate you need to use the ``--env`` option when starting
the docker image.

For example, setting the heap size:

    docker run -d -p 4200:4200 -p 4300:4300 --env CRATE_HEAP_SIZE=32g crate/crate

## Multicast

Crate uses multicast for node discovery by default. However, Docker does only support multicast on the same
host. This means that nodes that are started on the same host will discover each other automatically,
but nodes that are started on different hosts need unicast enabled.

You can enable unicast in your custom ``crate.yml``. See also: [Using Crate in a Multi Node Setup][7].

Due to its architecture, Crate publishes the host it runs on for discovery within the cluster. Since
the address of the host inside the docker container differs from the actual host the docker image is
running on, you need to tell Crate to publish the address of the docker host for discovery.

    docker run -d -p 4200:4200 -p 4300:4300 crate/crate crate -Des.network.publish_host=host1.example.com:

If you change the transport port from the default ``4300`` to something else, you also need to pass
the publish port to Crate.

    docker run -d -p 4200:4200 -p 4321:4300 crate/crate crate -Des.transport.publish_port=4321

### Example Usage in a Multinode Setup

    HOSTS='crate1.example.com:4300,crate2.example.com:4300,crate3.example.com:4300'
    HOST=crate1.example.com
    docker run -d \
        -p 4200:4200 \
        -p 4300:4300 \
        --name node1 \
        --volume /mnt/data:/data \
        --env CRATE_HEAP_SIZE=8g \
        crate/crate:latest \
        crate -Des.cluster.name=cratecluster \
              -Des.node.name=crate1 \
              -Des.transport.publish_port=4300 \
              -Des.network.publish_host=$HOST \
              -Des.multicast.enabled=false \
              -Des.discovery.zen.ping.unicast.hosts=$HOSTS \
              -Des.discovery.zen.minimum_master_nodes=2

## Crate Shell

The Crate Shell (`crash`) is bundled with the Docker image. Since the `crash`
executable is already in the `$PATH` environment variable, you can simply run:

    docker run --rm -ti crate/crate crash --hosts [host1, host2, ...]

Please refer to the [documentation][13] for usage instructions.


# License

View [license information][8] for the software contained in this image.


# User Feedback

## Issues

If you have any problems with, or questions about this image,
please contact us through a [GitHub issue][9].

If you have any questions or suggestions we would be very happy to help you.
So, feel free to join our [Crate.IO Slack Community][10].

For further information and official contact please visit [https://crate.io][3].

## Contributing

You are very welcome to contribute features or fixes! Before we can accept any pull requests to Crate
we need you to agree to our [CLA][11]. For further information please refer to [CONTRIBUTING.rst][12].



[1]: https://www.docker.com
[2]: https://registry.hub.docker.com/u/crate/crate/
[3]: https://crate.io
[4]: https://registry.hub.docker.com/
[5]: https://hub.docker.com/_/alpine/
[6]: https://crate.io/docs/stable/configuration.html
[7]: https://crate.io/docs/en/latest/best_practice/multi_node_setup.html
[8]: https://github.com/crate/crate/blob/master/LICENSE.txt
[9]: https://github.com/crate/docker-crate/issues
[10]: https://crate.io/docs/support/slackin/
[11]: https://crate.io/community/contribute/
[12]: https://github.com/crate/crate/blob/master/CONTRIBUTING.rst
[13]: https://crate.io/docs/projects/crash/en/latest/
