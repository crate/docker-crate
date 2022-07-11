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

    export CRATEDB_VERSION=5.0.0
    python3 update.py --cratedb-version ${CRATEDB_VERSION} > Dockerfile.probe
    docker build --file Dockerfile.probe --tag local/crate:${CRATEDB_VERSION} .

To introspect the software versions available, run::

    docker run -it --rm local/crate:${CRATEDB_VERSION} crate -v
    docker run -it --rm local/crate:${CRATEDB_VERSION} crash --version

For starting an instance of CrateDB and connecting to it, run::

    docker run -it --rm --name=cratedb --publish=4200:4200 --publish=5432:5432 local/crate:${CRATEDB_VERSION}
    docker exec -it cratedb crash

Run a vulnerability scan on the resulting image::

    grype --config .grype.yaml --only-fixed --fail-on medium local/crate:${CRATEDB_VERSION}
    trivy image --severity "CRITICAL,HIGH,MEDIUM" --ignore-unfixed --exit-code 1 local/crate:${CRATEDB_VERSION}

.. _contribution guide: https://github.com/crate/crate/blob/master/CONTRIBUTING.rst
