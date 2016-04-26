# -*- coding: utf-8 -*-
# vim: set fileencodings=utf-8
#
# Docker Integration Tests

from __future__ import absolute_import

import re
import sys
import time
from pprint import pprint
from crate.client import connect
from unittest import TestCase


class DockerBaseTestCase(TestCase):

    def __init__(self, layer):
        super(DockerBaseTestCase, self).__init__('testRun')
        self._layer = layer
        self.cli = layer.client
        self.container = None
        self.name = 'crate'
        self.is_running = False

    def connect(self, port=4200):
        crate_ip = '127.0.0.1'
        if self.cli.info()['OperatingSystem'].startswith(u'Boot2Docker'):
            import subprocess;
            crate_ip = subprocess.check_output(r'docker-machine ip',
                stderr=None, shell=True).decode("utf-8").strip('\n')
        return connect(['{0}:{1}'.format(crate_ip, str(port))])

    def setUp(self):
        pass

    def start(self, **docker_cmd):
        try:
            self._setUp(**docker_cmd)
        except Exception as e:
            # not a very good check
            if hasattr(e, response):
                regex = re.compile(r'[a-f0-9]{12}')
                _id = regex.findall(e.response.text)
                if _id and len(_id):
                    self.stop(_id[0])

    def _start(self, cmd='crate', ports={}, env=[]):
        self.container = self.cli.create_container(
            image=self._layer.tag,
            command=cmd,
            ports=list(ports.keys()),
            environment=env,
            name=self.name
        )
        self.cli.start(self.name, port_bindings=ports)
        process = self.crate_process()
        sys.stdout.write('Waiting for Docker container ')
        while not process.split()[0].endswith('java'):
            sys.stdout.write('.')
            time.sleep(0.1)
            process = self.crate_process()
        print('')
        self.is_running = True

    def tearDown(self):
        if self.container_id:
            self.stop(self.container_id)

    def stop(self, _id):
        self.cli.stop(_id)
        self.cli.remove_container(_id)
        self.container = None
        self.is_running = False

    @property
    def container_id(self):
        return self.container and self.container.get('Id') or None

    def info(self, key=None):
        top = self.cli and self.cli.top(self.name) or {}
        return key and top.get(key) or top

    def crate_process(self):
        proc = self.info(u'Processes')
        return proc and proc[0][2] or ''

    def logs(self):
        return self.cli.logs(self.name)

    def wait_for_cluster(self):
        print('Waiting for Crate to start ...')
        for line in self.cli.logs(self.name, stream=True):
            l = line.decode("utf-8").strip('\n').strip()
            print(l)
            if l.endswith('started'):
                break

def docker(cmd, ports={}, env=[]):
    def wrap(fn):
        def inner_fn(self, *args, **kwargs):
            print(self.__class__.__doc__)
            self._start(cmd=cmd, ports=ports, env=env)
            fn(self)
        return inner_fn
    return wrap


class SimpleRunTest(DockerBaseTestCase):
    """
    docker run crate crate
    """

    @docker(['crate'], ports={}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        lg = self.logs().decode("utf-8").split('\n')
        self.assertTrue(lg[-3:][0].endswith('(elected_as_master)'))
        self.assertTrue(lg[-2:][0].endswith('started'))

class JavaPropertiesTest(DockerBaseTestCase):
    """
    docker run -p 4200:4200 crate crate -Des.cluster.name=foo -Des.node.name=bar
    """

    @docker(['crate', '-Des.cluster.name=foo', '-Des.node.name=bar'], ports={4200:4200}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        cursor = self.connect().cursor()
        # cluster name
        cursor.execute('''select name from sys.cluster''')
        res = cursor.fetchall()
        self.assertEqual(res[0][0], 'foo')
        # node name
        cursor.execute('''select name from sys.nodes''')
        res = cursor.fetchall()
        self.assertEqual(res[0][0], 'bar')


class EnvironmentVariablesTest(DockerBaseTestCase):
    """
    docker run -p 4200:4200 --env CRATE_HEAP_SIZE=1048576000 crate crate
    """

    @docker(['crate'], ports={4200:4200}, env=['CRATE_HEAP_SIZE=1048576000'])
    def testRun(self):
        self.wait_for_cluster()
        # check -Xmx and -Xms process arguments
        process = self.crate_process()
        res = re.findall(r'-Xm[\S]+', process)
        self.assertEqual('1048576000', res[0][len('-Xmx'):])
        self.assertEqual('1048576000', res[0][len('-Xms'):])


class SigarStatsTest(DockerBaseTestCase):
    """
    docker run -p 4200:4200 crate crate
    """

    @docker(['crate'], ports={4200:4200}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        cursor = self.connect().cursor()

        cursor.execute("select os['cpu'] from sys.nodes limit 1")
        self.assert_not_fallback_values(cursor.fetchall())

        cursor.execute("select mem from sys.nodes limit 1")
        self.assert_not_fallback_values(cursor.fetchall())

    def assert_not_fallback_values(self, result):
        for entry in result:
            for _, value in entry[0].items():
                self.assertNotEqual(value, -1)
