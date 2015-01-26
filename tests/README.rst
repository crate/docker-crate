Crate Docker Image Development
==============================

Running Tests
-------------

This project uses `buildout <https://pypi.python.org/pypi/zc.buildout/>`_
to setup the testing environment for ``docker-crate``.

Run ``bootstrap.py``::

    python bootstrap.py

And afterwards run buildout::

    ./bin/buildout -N

Additionally it requires `Docker <https://www.docker.com>`_ to be installed on the local machine.
For OSX you'd need to install `boot2docker <https://boot2docker.io>`_.

The tests are run using the `zope.testrunner <https://pypi.python.org/pypi/zope.testrunner>`_.
To run the tests::

    ./bin/test


