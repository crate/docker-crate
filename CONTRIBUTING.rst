============
Contributing
============

Thank you for your interest in contributing.

Please see the CrateDB `contribution guide`_ for more information. Everything in
the CrateDB contribution guide also applies to this repository.


Usage
=====

In order to create a Dockerfile for local testing and create a container image,
use those commands::

    # Create Dockerfile for building a GA image
    export CRATEDB_VERSION=5.0.0
    python3 update.py --cratedb-version ${CRATEDB_VERSION} > Dockerfile-${CRATEDB_VERSION}

    # Create Dockerfile for building a nightly image
    export CRATEDB_VERSION=5.0.0-202207120003-fb24ad5
    python3 update.py --cratedb-tarball https://cdn.crate.io/downloads/releases/nightly/crate-${CRATEDB_VERSION}.tar.gz > Dockerfile-${CRATEDB_VERSION}

    # Build
    docker build --file Dockerfile-${CRATEDB_VERSION} --tag local/crate:${CRATEDB_VERSION} .

To introspect the software versions available, run::

    docker run -it --rm local/crate:${CRATEDB_VERSION} crate -v
    docker run -it --rm local/crate:${CRATEDB_VERSION} crash --version

For starting an instance of CrateDB and connecting to it, run::

    docker run -it --rm --name=cratedb --publish=4200:4200 --publish=5432:5432 local/crate:${CRATEDB_VERSION}
    docker exec -it cratedb crash

Run a vulnerability scan on the resulting image::

    grype --only-fixed --fail-on medium local/crate:${CRATEDB_VERSION}
    trivy image --severity "CRITICAL,HIGH,MEDIUM" --ignore-unfixed --exit-code 1 local/crate:${CRATEDB_VERSION}

.. _contribution guide: https://github.com/crate/crate/blob/master/CONTRIBUTING.rst
