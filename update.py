#!/usr/bin/env python3

import argparse
import json
import os
import re
from datetime import datetime
from jinja2 import Environment, FileSystemLoader
from typing import NamedTuple, Optional, Tuple
from urllib.error import URLError
from urllib.request import urlopen, Request
from urllib.parse import urljoin

RELEASE_URL = 'https://cdn.crate.io/downloads/releases/'
CRATEDB_RELEASE_URL = 'https://cdn.crate.io/downloads/releases/cratedb'
CRATEDB_NIGHTLY_URL = 'https://cdn.crate.io/downloads/releases/nightly'

JDK_URLS = {
    (13, 0, 1): 'https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz',
    (12, 0, 1): 'https://download.java.net/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_linux-x64_bin.tar.gz',
    (11, 0, 1): 'https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz'
}


class Version(NamedTuple):
    major: int
    minor: int
    hotfix: int
    snapshot: str = None

    @classmethod
    def parse(cls, s: str):
        if s is None:
            return None
        parts = s.split('.', maxsplit=2)
        snapshot_parts = parts[2].split('-', maxsplit=1)
        if len(snapshot_parts) > 1:
            return Version(int(parts[0]), int(parts[1]), int(snapshot_parts[0]), snapshot_parts[1])
        return Version(*map(int, parts))

    def __str__(self) -> str:
        if self.snapshot is None:
            return f'{self.major}.{self.minor}.{self.hotfix}'
        return f'{self.major}.{self.minor}.{self.hotfix}-{self.snapshot}'



def latest_crash() -> Version:
    with urlopen('https://crate.io/versions.json') as r:
        d = json.load(r)
        return Version.parse(d['crash'])


def jdk_url_and_sha(jdk_version):
    if jdk_version not in JDK_URLS:
        raise ValueError(f'No URL for JDK version {jdk_version} found.')
    url = JDK_URLS[jdk_version]
    with urlopen(url + '.sha256') as r:
        sha256 = r.read().decode('utf-8')
    return url, sha256


def url_exists(url: str) -> bool:
    try:
        with urlopen(Request(url, method='HEAD')):
            return True
    except URLError:
        return False


def ensure_existing_crash_release(crash_version: Version) -> Tuple[Version, str]:
    if not crash_version:
        crash_version = latest_crash()
    url = RELEASE_URL + f'crash_standalone_{crash_version}'
    if url_exists(url):
        return crash_version, url
    else:
        raise ValueError(f'No release found for crash {crash_version}')


def ensure_existing_cratedb_release(cratedb_version: Version, platform: str) -> str:
    cratedb_tarball = f'crate-{cratedb_version}.tar.gz'
    if isinstance(cratedb_version, tuple):
        if cratedb_version >= (4, 2, 0):
            url = urljoin(urljoin(CRATEDB_RELEASE_URL + '/', platform + '/'), cratedb_tarball)
        else:
            url = urljoin(RELEASE_URL, cratedb_tarball)
    else:
        url = urljoin(RELEASE_URL, cratedb_version)
    if url_exists(url):
        return url
    else:
        raise ValueError(f'No release found for CrateDB {cratedb_tarball} at {url}')


def version_from_url(url: str) -> Optional[Version]:
    pattern = re.compile(r"(.*/)?crate-(\d+.\d+.\d+(?:-.*)?).tar.gz")
    matches = pattern.match(url)
    if matches:
        return Version.parse(matches.group(2))
    return None


def find_template_for_version(cratedb_version: Version) -> str:
    v = cratedb_version
    if v.snapshot is not None:
        template = 'Dockerfile_nightly.j2'
        versioned_template = f'Dockerfile_{v.major}.{v.minor}_nightly.j2'
    else:
        template = 'Dockerfile.j2'
        versioned_template = f'Dockerfile_{v.major}.{v.minor}.j2'
    return versioned_template if os.path.exists(versioned_template) else template


def get_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    cratedb = parser.add_mutually_exclusive_group(required=True)
    cratedb.add_argument('--cratedb-version', type=Version.parse)
    cratedb.add_argument('--cratedb-tarball', type=str)
    parser.add_argument(
        '--platform',
        type=str,
        default="x64_linux",
        choices=['x64_linux', 'aarch64_linux'],
        help='The target system architecture.')
    parser.add_argument('--crash-version', type=Version.parse)
    parser.add_argument('--jdk-version', type=Version.parse)
    parser.add_argument('--template', type=str)
    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    platform = args.platform
    if args.cratedb_version:
        cratedb_version = args.cratedb_version
        cratedb_url = ensure_existing_cratedb_release(cratedb_version, platform)
    if args.cratedb_tarball:
        cratedb_url = ensure_existing_cratedb_release(args.cratedb_tarball, platform)
        cratedb_version = version_from_url(cratedb_url)

    assert cratedb_version and cratedb_url

    crash_version, crash_url = ensure_existing_crash_release(args.crash_version)
    if cratedb_version >= (4, 1, 0):
        jdk_version_default = (13, 0, 1)
    elif cratedb_version >= (4, 0, 0):
        jdk_version_default = (12, 0, 1)
    else:
        jdk_version_default = (11, 0, 1)
    jdk_version = args.jdk_version or jdk_version_default
    jdk_url, jdk_sha256 = jdk_url_and_sha(jdk_version)
    template = args.template or find_template_for_version(cratedb_version)

    env = Environment(loader=FileSystemLoader(os.path.dirname(__file__)))
    template = env.get_template(template)
    print(template.render(
        CRATE_VERSION=cratedb_version,
        CRATE_RELEASE_URL=CRATEDB_RELEASE_URL if cratedb_version.snapshot is None else CRATEDB_NIGHTLY_URL,
        CRATE_URL=cratedb_url, # for versions < 4.2
        CRASH_VERSION=crash_version,
        CRASH_URL=crash_url,
        JDK_VERSION=jdk_version,
        JDK_URL=jdk_url,
        JDK_SHA256=jdk_sha256,
        BUILD_TIMESTAMP=datetime.utcnow().isoformat()
    ))


if __name__ == "__main__":
    main()
