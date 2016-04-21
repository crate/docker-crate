.. highlight: sh

Crate Docker Image Development
==============================

Running Tests
-------------

This project uses `buildout <https://pypi.python.org/pypi/zc.buildout/>`_
to setup the testing environment for ``docker-crate``.

Run ``bootstrap.py``::

  >>> python3.4 bootstrap.py

And afterwards run buildout::

  >>> ./bin/buildout -N

Additionally it requires `Docker <https://www.docker.com>`_ version `1.10.x`
with API version `1.22` to be installed on the local machine::

  >>> docker version
  Client:
   Version:      1.10.3
   API version:  1.22
   Go version:   go1.5.3
   Git commit:   20f81dd
   Built:        Thu Mar 10 21:49:11 2016
   OS/Arch:      darwin/amd64
  Server:
   Version:      1.10.3
   API version:  1.22
   Go version:   go1.5.3
   Git commit:   20f81dd
   Built:        Thu Mar 10 21:49:11 2016
   OS/Arch:      linux/amd64

For OSX you would need to install `Docker Toolbox <https://www.docker.com/products/docker-toolbox>`_
and initialize the Docker environment using the Quickstart Terminal::

  >>> /bin/bash -c "/Applications/Docker/Docker\ Quickstart\ Terminal.app/Contents/Resources/Scripts/start.sh"

The tests are run using the `zope.testrunner <https://pypi.python.org/pypi/zope.testrunner>`_.
To run the tests::

  >>> ./bin/test
