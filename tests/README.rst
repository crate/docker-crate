.. highlight: sh

Crate Docker Image Development
==============================

Running Tests
-------------

Create a virtual environment::

  >>> python3 -m venv .venv

Then activate it::

  >>> source .venv/bin/activate

Now use pip to install the dependencies::

  >>> pip install -r requirements.txt

The tests require `Docker <https://www.docker.com>`_ version `1.10.x`
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

For CrateDB >= 1.2 you would need to change the following setting in your docker machine::

  >>> docker-machine ssh default "sudo sysctl -w vm.max_map_count=262144"

To run the tests::

  >>> PATH_TO_IMAGE=amd64/crate zope-testrunner --path . -s tests --color

Where ``PATH_TO_IMAGE`` is a root-relative path to a folder with a Dockerfile.
