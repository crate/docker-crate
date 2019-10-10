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

RELEASE_URL = 'https://cdn.crate.io/downloads/releases/'
JDK_URLS = {
    (13, 0, 0): 'https://download.java.net/java/GA/jdk13/5b8a42f3905b406298b72d750b6919f6/33/GPL/openjdk-13_linux-x64_bin.tar.gz',
    (12, 0, 1): 'https://download.java.net/java/GA/jdk12.0.1/69cfe15208a647278a19ef0990eea691/12/GPL/openjdk-12.0.1_linux-x64_bin.tar.gz',
    (11, 0, 1): 'https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz'
}


class Version(NamedTuple):
    major: int
    minor: int
    hotfix: int

    @classmethod
    def parse(cls, s: str):
        return Version(*map(int, s.split('.', maxsplit=2))) if s else None

    def __str__(self) -> str:
        return f'{self.major}.{self.minor}.{self.hotfix}'


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


def ensure_existing_cratedb_release(cratedb_tarball: str) -> str:
    url = RELEASE_URL + cratedb_tarball
    if url_exists(url):
        return url
    else:
        raise ValueError(f'No release found for CrateDB {cratedb_tarball}')


def version_from_url(url: str) -> Optional[Version]:
    pattern = re.compile(r"(.*/)?crate-(\d+.\d+.\d+)(-.*)?.tar.gz")
    matches = pattern.match(url)
    if matches:
        return Version.parse(matches.group(2))
    return None


def find_template_for_version(cratedb_version: Version) -> str:
    v = cratedb_version
    versioned_template = f'Dockerfile_{v.major}.{v.minor}.j2'
    return versioned_template if os.path.exists(versioned_template) else 'Dockerfile.j2'


def get_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    cratedb = parser.add_mutually_exclusive_group(required=True)
    cratedb.add_argument('--cratedb-version', type=Version.parse)
    cratedb.add_argument('--cratedb-tarball', type=str)
    parser.add_argument('--crash-version', type=Version.parse)
    parser.add_argument('--jdk-version', type=Version.parse)
    parser.add_argument('--template', type=str)
    return parser


def main():
    parser = get_parser()
    args = parser.parse_args()

    if args.cratedb_version:
        cratedb_version = args.cratedb_version
        cratedb_url = ensure_existing_cratedb_release(f'crate-{cratedb_version}.tar.gz')
    if args.cratedb_tarball:
        cratedb_url = ensure_existing_cratedb_release(args.cratedb_tarball)
        cratedb_version = version_from_url(cratedb_url)

    assert cratedb_version and cratedb_url

    crash_version, crash_url = ensure_existing_crash_release(args.crash_version)
    jdk_version_default = Version(13, 0, 0) if cratedb_version.major >= 4 else Version(12, 0, 1)
    jdk_version = args.jdk_version or jdk_version_default
    jdk_url, jdk_sha256 = jdk_url_and_sha(jdk_version)
    template = args.template or find_template_for_version(cratedb_version)

    env = Environment(loader=FileSystemLoader(os.path.dirname(__file__)))
    template = env.get_template(template)
    print(template.render(
        CRATE_VERSION=cratedb_version,
        CRATE_URL=cratedb_url,
        CRASH_VERSION=crash_version,
        CRASH_URL=crash_url,
        JDK_VERSION=jdk_version,
        JDK_URL=jdk_url,
        JDK_SHA256=jdk_sha256,
        BUILD_TIMESTAMP=datetime.utcnow().isoformat()
    ))


if __name__ == "__main__":
    main()
