
## Docker Image for building Sigar libraries

In order to support [Sigar][1] on Linux distrbutions which use [musl libc][2]
C standard library instead of [glibc][3], e.g. [**Alpine Linux**][4]. It's
necessary to build [**Sigar**][1] libraries from source using corresponding
dependencies.

### Build Sigar Docker Image

```sh
docker build -t sigar .
```

### Launch Sigar Container

To build [**Sigar**][1] libraries run the Sigar Docker container. The libraries
can be found in the mounted output directory.

```sh
docker run -v <output dir>:/out sigar
```

[1]: https://github.com/hyperic/sigar
[2]: http://www.musl-libc.org/
[3]: https://www.gnu.org/software/libc/
[4]: http://www.alpinelinux.org/
