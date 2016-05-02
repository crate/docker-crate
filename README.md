# What is Crate?

Crate is a fast, scalable, easy to use SQL database that plays nicely
with containers like Docker. It feels like the SQL databases you know,
however makes scaling and operating your database ridiculously easy --
regardless of the volume, complexity, or type of data. Crate is open
source. It ingests millions of records per second for time series
setups and delivers analytics results in subsecond real time.

It comes with a distributed sort and aggregation engine, fast multi
index queries, native full-text search and super simple scalability
with sharding and partitioning builtin already. Preconfigured
replication takes care of data resiliency. The cluster management can
easily supervised with its builtin admin UI. Crate's masterless
architecture and simplicity make the data part of Docker environments
easy and elegant.

Crate provides several installation packages, including a supported
Docker image. It fits perfectly in an orchestrated microservices
environment. It acts like an ether, an omnipresent, persistent layer
for data. This way, application containers access their data
regardless on which host the data nodes run.

[Crate: Put your data to work. Simply.](https://crate.io/)

## Building Images

Crate derives from
[alpine:latest](https://hub.docker.com/_/alpine/). We build this
nightly updated image from the `Dockerfile` on GitHub:

    docker build -t="crate/crate" github.com/crate/docker-crate

To build your own image, replace the image name after the `-t` option
with your own name.

Alternativly, an [Official Crate
Image](https://hub.docker.com/_/crate/) with the name `crate` is
available in the Docker Hub. That image is based on a stable major
version of Crate, and is tested and scanned by Docker, Inc.

## How to use this image

To form a cluster, just start the Crate container a few times in the
background. This starts a couple of containers on your machine which
discover each other via multicast. In a production environment you'd
run Crate on different machines:

```console
# docker run -d crate/crate
```

To access the admin UI, point your browser to port tcp/4200 of a data
node of your choice while you start it or look up its IP later on:

```console
# firefox "http://$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $(docker run -d crate/crate)):4200/admin"
```

## Attach persistent data directory

Crate stores all important data in `/data`. To attach it to a backup
service, map the directory to the host:

```console
# docker run -d -v <data-dir>:/data crate/crate
```

Note, that there are way more sophisticated ways to [backup data with
builtin commands like `CREATE
SNAPSHOT`](https://crate.io/a/backing-up-and-restoring-crate/).

## Use custom Crate configuration

Crate is basically controlled by a single configuration file which has
sensible defaults already. If you derive your container from the Crate
container and place your file inside it and let Crate know where to
find it:

```console
# docker run -d crate/crate -Des.config=</path/to>/crate.yml
```

Other configuration settings may be specified upon startup using the
`-D` option prefix. For example, configuring the cluster name by using
system properties will work this way:

```console
# docker run -d crate/crate -Des.cluster.name=<my-cluster-name>
```

For further configuration options please refer to the
[Configuration](https://crate.io/docs/stable/configuration.html)
section of the online documentation.

## Environment

Crate recognizes a few environment variables like `CRATE_HEAP_SIZE`
that need to be set with the `--env` option before the actual Crate
core starts. You may want to [assign about half of your memory
it](https://crate.io/docs/reference/en/latest/configuration.html#crate-heap-size)
as a rule of thumb to Crate like this:

```console
# docker run -d --env CRATE_HEAP_SIZE=32g crate/crate
```

## Open Files

Depending on the size of your installation Crate opens a lot of
files. You can check the number of open files with `ulimit -n`. It
depends on your host operation system. To increase the number start
containers with the option `--ulimit nofile=65535:65535`:

## Multicast

Crate uses multicast for node discovery by default. This means nodes
started in the same multicast zone will discover each other
automatically. However, Docker multicast support between containers on
different hosts depends on the overlay network driver. If that does
not support multicast, you have to [enable unicast in your custom
`crate.yml`](https://crate.io/docs/reference/best_practice/multi_node_setup.html).

Crate publishes the hostname it runs on for discovery within the
cluster. If the address of the docker container differs from the
actual host the docker image is running on -- this is the case if you
do port mapping to the host via the `-p` option, you need to tell
Crate to publish the address of the docker host instead:

```console
# docker run -d -p 4200:4200 -p 4300:4300 crate/crate \
    crate -Des.network.publish_host=host1.example.com
```

If you change the transport port from the default `4300` to something
else, you also need to pass the publish port to Crate by adding
`-Des.transport.publish_port=4321` to your command.

## Example Usage in a Multihost Setup

To start a Crate cluster in containers distributed to three hosts
without multicast enabled, run this command on the first node and
adapt container and node names on the two other nodes:

```console
# HOSTS="crate1.example.com:4300,crate2.example.com:4300,crate3.example.com:4300"
# HOST="crate1.example.com"
# docker run -d -P \
    --name crate1-container \
    --volume /mnt/data:/data \
    --env CRATE_HEAP_SIZE=8g \
        crate/crate \
	crate -Des.cluster.name=cratecluster \
              -Des.node.name=crate1 \
              -Des.transport.publish_port=4300 \
              -Des.network.publish_host="$HOST" \
              -Des.multicast.enabled=false \
              -Des.discovery.zen.ping.unicast.hosts="$HOSTS" \
              -Des.discovery.zen.minimum_master_nodes=2
```

## Crate Shell

The Crate Shell `crash` is bundled with the Docker image. Since the
`crash` executable is already in the `$PATH` environment variable,
simply run:

```console
# docker run --rm -ti crate/crate crash --hosts [host1, host2, ...]
```

Please refer to the
[documentation](https://crate.io/docs/projects/crash/en/latest/) for
usage instructions.

## License

View [license
information](https://github.com/crate/crate/blob/master/LICENSE.txt)
for the software contained in this image.

## Supported Docker versions

This image is officially supported on Docker version 1.11.1. Support
for older versions (down to 1.6) is provided on a best-effort basis.

## Documentation

Documentation for this image is stored in the [`crate/docker-crate`
GitHub repo](https://github.com/crate/docker-crate). More info about
running [Crate in a Docker container](https://crate.io/c/docker) is
available in our [documentation](https://crate.io/docs).

## Issues

If you have any problems with or questions about this image, please
contact us through a [GitHub
issue](https://github.com/crate/docker-crate/issues).

If you have any questions or suggestions, we are happy to help! Feel
free to join our [public Crate community on
Slack](https://crate.io/docs/support/slackin/).

For further information and official contact visit
[https://crate.io](https://crate.io).

## Contributing

You are welcome to contribute features or fixes! Before we can accept
any pull requests to Crate we need you to agree to our
[CLA](https://crate.io/community/contribute/). For further information
please refer to
[CONTRIBUTING.rst](https://github.com/crate/crate/blob/master/CONTRIBUTING.rst).
