import os
import sys
import json


DEBUG = os.environ.get('BUILD_DEBUG', 'false').lower() == 'true'


def _print_debug(line):
    """Print full docker build output"""
    stream = json.loads(line.decode('utf-8')).get('stream')
    if stream:
        sys.stdout.write('  ' + stream)
        sys.stdout.flush()


def _print_short(line):
    """Print dot for each docker build step"""
    sys.stdout.write('.')
    sys.stdout.flush()


def _noop(*args):
    """Don't print anything"""
    pass


print_build_output = _print_debug if DEBUG else _print_short
print_debug = print if DEBUG else _noop
