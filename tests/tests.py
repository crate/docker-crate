# -*- coding: utf-8 -*-
# vim: set fileencodings=utf-8

__docformat__ = "reStructuredText"

import os
import sys
import json
import time
import signal
import logging

import doctest
import unittest
import zc.customdoctests

from pprint import pprint
from requests.exceptions import ConnectionError
from docker import Client
from docker.utils import kwargs_from_env

from itests import SimpleRunTest, JavaPropertiesTest, EnvironmentVariablesTest

logger = logging.getLogger(__name__)

DIR = os.path.dirname(__file__)

class RuntimeError(Exception):
    pass

class DockerLayer(object):

    def __init__(self, name, tag):
        self.__name__ = name
        self.__bases__ = tuple([])
        self.tag = tag
        self.client = Client(base_url='unix://var/run/docker.sock')
        try:
            self.client.ping()
        except ConnectionError as e:
            # http://docker-py.readthedocs.org/en/latest/boot2docker/
            kwargs = kwargs_from_env()
            kwargs['tls'].assert_hostname = False
            self.client = Client(**kwargs)

    def setUp(self):
        if self.client.ping() == u'OK':
            self.start()
        else:
            raise RuntimeError('Docker is not available.\nMake sure you have Docker installed before running tests.\nVisit https://docker.com for installation instructions.')

    def start(self):
        for line in self.client.build(
                path=os.path.abspath(os.path.join(DIR, '..')),
                tag=self.tag, rm=True, forcerm=True):
            sys.stdout.write(line)

    def tearDown(self):
        self.stop()

    def stop(self):
        self.client.close()


def test_suite():
    docker_layer = DockerLayer('docker', 'crate/crate:test')
    suite = unittest.TestSuite()
    suite.addTest(SimpleRunTest(docker_layer))
    suite.addTest(JavaPropertiesTest(docker_layer))
    suite.addTest(EnvironmentVariablesTest(docker_layer))
    suite.layer = docker_layer
    return suite

