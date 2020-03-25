# vim: set fileencodings=utf-8

__docformat__ = "reStructuredText"

import os
import sys
import docker
import unittest

from .utils import print_build_output
from .itests import SimpleRunTest,  JavaPropertiesTest, CrateHeapSizeTest, \
    CrateJavaOptsTest, NodeStatsTest, TarballRemovedTest, MountedDataDirectoryTest

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
        path_to_image = os.path.join(DIR, '..', os.environ.get('PATH_TO_IMAGE'))
        print(os.path.abspath(path_to_image))
        for line in self.client.build(
                path=os.path.abspath(path_to_image),
                tag=self.tag,
                rm=True,
                forcerm=True):
            print_build_output(line)
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
    suite.addTest(CrateHeapSizeTest(docker_layer))
    suite.addTest(CrateJavaOptsTest(docker_layer))
    suite.addTest(NodeStatsTest(docker_layer))
    suite.addTest(TarballRemovedTest(docker_layer))
    suite.addTest(MountedDataDirectoryTest(docker_layer))
    suite.layer = docker_layer
    return suite
