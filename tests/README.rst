.. highlight: sh

==============================
Crate Docker Image Development
==============================


Prerequisites
=============

For invoking the next steps, you will need to have Docker and Python installed
on your computer.

First, create a virtual environment and install the Python dependencies::

    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt


Configuring ``vm.max_map_count``
================================

It is important that the system-wide ``vm.max_map_count`` setting is configured
to a higher value than the default one, see also `adjust system limits on
Linux`_. On most default installations of Docker Desktop, it is already
configured to ``262144`` today, but it was ``65530`` for previous releases.

You can easily check this on your machine by running::

    docker run --rm -it busybox sysctl vm.max_map_count

If you see a lower value, you should adjust the setting correspondingly.


Configuration on Linux
----------------------

- Ad hoc: Invoke ``sudo sysctl -w vm.max_map_count=262144``.
- Persistent: Add ``vm.max_map_count = 262144`` to ``/etc/sysctl.conf`` or
  ``/etc/sysctl.d/``, then invoke ``sysctl --system``, or reboot.


Configuration on macOS
----------------------

Ad hoc::

    docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh
    sysctl -w vm.max_map_count=262144


Configuration on Windows
------------------------

Depending on the Docker backend you are using on Windows (WSL2 vs. Hyper-V),
the setting may show a default value of ``65530``, or ``262144``.

In order to adjust the value, add this snippet to ``%userprofile%\.wslconfig``,
for example ``C:\Users\<username>\.wslconfig``, invoke ``wsl --shutdown``, and
restart::

    [wsl2]
    kernelCommandLine = "sysctl.vm.max_map_count=262144"

Please note that your WSL Linux machine must be running Linux kernel release
5.8 or higher in order to use this recipe.


Running tests
=============

To run the tests::

    PATH_TO_IMAGE=. zope-testrunner --path . -s tests --color

Where ``PATH_TO_IMAGE`` is a root-relative path to a folder with a Dockerfile.


.. _adjust system limits on Linux: https://crate.io/docs/crate/howtos/en/latest/admin/bootstrap-checks.html#linux

