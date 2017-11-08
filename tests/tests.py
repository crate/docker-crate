# -*- coding: utf-8 -*-
# vim: set fileencodings=utf-8

__docformat__ = "reStructuredText"

import os
import sys

import docker
import unittest

from requests.exceptions import ConnectionError

from itests import SimpleRunTest, JavaPropertiesTest, \
    EnvironmentVariablesTest, SigarStatsTest, TarballRemovedTest

DIR = os.path.dirname(__file__)

class RuntimeError(Exception):
    pass

class DockerLayer(object):

    def __init__(self, name, tag):
        self.__name__ = name
        self.__bases__ = tuple([])
        self.tag = tag
        self.client = docker.APIClient(base_url='unix://var/run/docker.sock')

    def setUp(self):
        if self.client.ping():
            self.start()
        else:
            raise RuntimeError('Docker is not available.\n'
                               'Make sure you have Docker installed before running tests.\n'
                               'Visit https://docker.com for installation instructions.')

    def start(self):
        sys.stdout.write('\nBuilding container {}\n'.format(self.tag))
        for line in self.client.build(
                path=os.path.abspath(os.path.join(DIR, '..')),
                tag=self.tag, rm=True, forcerm=True):
            sys.stdout.write('.')
        sys.stdout.write('\n')

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
    suite.addTest(SigarStatsTest(docker_layer))
    suite.addTest(TarballRemovedTest(docker_layer))
    suite.layer = docker_layer
    return suite

