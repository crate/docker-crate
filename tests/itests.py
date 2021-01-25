# vim: set fileencodings=utf-8
#
# Docker Integration Tests

import re
import time
import unittest

from tempfile import mkdtemp
from shutil import rmtree
from psycopg2 import connect
from .utils import print_debug


class InvalidState(Exception):
    pass


class DockerBaseTestCase(unittest.TestCase):

    def __init__(self, layer):
        super(DockerBaseTestCase, self).__init__('testRun')
        self._layer = layer
        self.cli = layer.client
        self.container = None
        self.name = 'crate'
        self.is_running = False

    def connect(self, port=55432, user='crate'):
        crate_ip = '127.0.0.1'
        if self.cli.info()['OperatingSystem'].startswith(u'Boot2Docker'):
            import subprocess
            crate_ip = subprocess.check_output(r'docker-machine ip',
                                               stderr=None, shell=True).decode("utf-8").strip('\n')
        return connect(host=crate_ip, port=port, user=user)

    def start(self, cmd=['crate'], ports={}, env=[], volumes={}):
        if self.is_running:
            raise InvalidState('Container is still running.')

        ulimits = [dict(name='memlock', soft=-1, hard=-1)]
        host_conf = self.cli.create_host_config(
            port_bindings=ports,
            binds=volumes,
            ulimits=ulimits,
        )

        self.assertTrue(len(cmd) >= 1)
        self.assertEqual(cmd[0], 'crate')

        cmd[1:1] = [
            '-Cbootstrap.memory_lock=true',
        ]
        env[0:0] = [
            'CRATE_HEAP_SIZE=128m',
        ]

        self.container = self.cli.create_container(
            image=self._layer.tag,
            command=cmd,
            ports=list(ports.keys()),
            host_config=host_conf,
            environment=env,
            volumes=['/data'],
            name=self.name
        )
        self.cli.start(self.container_id)
        process = self.crate_process()
        print_debug('Waiting for Docker container ...')
        while not process:
            time.sleep(0.1)
            process = self.crate_process()
        self.is_running = True

    def setUp(self):
        pass

    def tearDown(self):
        if self.container_id:
            self.stop(self.container_id)

    def stop(self, _id):
        self.cli.stop(_id)
        self.cli.remove_container(_id)
        self.container = None
        time.sleep(1)
        self.is_running = False

    @property
    def container_id(self):
        return self.container and self.container.get('Id') or None

    def info(self, key=None):
        top = self.cli and self.cli.top(self.name) or {}
        return key and top.get(key) or top

    def crate_process(self):
        procs = self.info(u'Processes')
        if not procs:
            return ''

        for proc in procs:
            for p in proc:
                if p.startswith('/opt/jdk') or p.startswith('/crate/jdk'):
                    print_debug('>>>', p)
                    return p
        return ''

    def logs(self):
        return self.cli.logs(self.name)

    def wait_for_cluster(self):
        print_debug('Waiting for CrateDB to start ...')
        for line in self.cli.logs(self.name, stream=True):
            l = line.decode("utf-8").strip('\n').strip()
            print_debug(l)
            if "[ERROR" in l:
                self.fail("Error in logs")
            if l.endswith('started'):
                break


def docker(cmd, ports={}, env=[], volumes={}):
    def wrap(fn):
        def inner_fn(self, *args, **kwargs):
            print_debug(self.__class__.__doc__)
            self.start(cmd=cmd, ports=ports, env=env, volumes=volumes)
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
        self.assertIn('elected-as-master', lg[-5:][0])
        self.assertIn('started', lg[-2:][0])


class JavaPropertiesTest(DockerBaseTestCase):
    """
    docker run crate crate -Ccluster.name=foo crate -Cnode.name=bar
    """

    @docker(['crate', '-Ccluster.name=foo', '-Cnode.name=bar'],
            ports={5432:55432}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        conn = self.connect(port=55432)
        with conn.cursor() as cursor:
            # cluster name
            cursor.execute('''select name from sys.cluster''')
            res = cursor.fetchall()
            self.assertEqual(res[0][0], 'foo')
            # node name
            cursor.execute('''select name from sys.nodes''')
            res = cursor.fetchall()
            self.assertEqual(res[0][0], 'bar')
        conn.close()


class CrateHeapSizeTest(DockerBaseTestCase):
    """
    docker run --env CRATE_HEAP_SIZE=256m crate
    """

    @docker(['crate'], ports={}, env=['CRATE_HEAP_SIZE=256m'])
    def testRun(self):
        self.wait_for_cluster()
        # check -Xmx and -Xms process arguments
        process = self.crate_process()
        res = re.findall(r'-Xm[\S]+', process)
        self.assertEqual('256m', res[0][len('-Xmx'):])
        self.assertEqual('256m', res[0][len('-Xms'):])


class CrateJavaOptsTest(DockerBaseTestCase):
    """
    docker run --env CRATE_JAVA_OPTS="-Dcom.sun.management.jmxremote" crate
    """

    @docker(['crate'], ports={}, env=['CRATE_JAVA_OPTS=-Dcom.sun.management.jmxremote'])
    def testRun(self):
        self.wait_for_cluster()

        # check -XX process arguments
        process = self.crate_process()
        res = re.findall(r'-XX:[\S]+', process)
        opts = [r[4:] for r in res]  # strip -XX: prefix
        # default java options
        self.assertTrue('+UseG1GC' in opts)
        self.assertTrue('+DisableExplicitGC' in opts)

        # check -D process arguments
        res = re.findall(r'-D[\S]+', process)
        opts = [r[2:] for r in res]  # strip -D prefix
        # crate docker java options
        self.assertTrue('es.cgroups.hierarchy.override=/' in opts)
        # explicitly set java option
        self.assertTrue('com.sun.management.jmxremote' in opts)


class MountedDataDirectoryTest(DockerBaseTestCase):
    """
    docker run --volume $(mktemp -d):/data crate
    """

    VOLUMES = {
        '/data': {
            'bind': mkdtemp(),
            'mode': 'rw',
        }
    }

    @docker(['crate'],
            ports={},
            env=[],
            volumes=VOLUMES)
    def testRun(self):
        self.wait_for_cluster()

        id = self.cli.exec_create('crate', 'ls /data')
        res = self.cli.exec_start(id['Id'])
        self.assertEqual(b'blobs\ndata\nlog\n', res)

    def tearDown(self):
        rmtree(self.VOLUMES['/data']['bind'])
        super().tearDown()


class NodeStatsTest(DockerBaseTestCase):
    """
    docker run crate
    """

    @docker(['crate'], ports={5432:55432}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        conn = self.connect(port=55432)
        with conn.cursor() as cursor:
            cursor.execute("select load from sys.nodes limit 1")
            self.assert_not_fallback_values(cursor.fetchall())
            cursor.execute("select mem from sys.nodes limit 1")
            self.assert_not_fallback_values(cursor.fetchall())
        conn.close()

    def assert_not_fallback_values(self, result):
        for entry in result:
            for _, value in entry[0].items():
                self.assertNotEqual(value, -1)


class TarballRemovedTest(DockerBaseTestCase):
    """
    docker run crate /bin/sh -c 'ls -la /crate-*'
    """

    @docker(['crate'], ports={}, env=[])
    def testRun(self):
        self.wait_for_cluster()
        id = self.cli.exec_create('crate', 'ls -la /crate-*')
        res = self.cli.exec_start(id['Id'])
        self.assertEqual(b'ls: cannot access /crate-*: No such file or directory\n', res)
