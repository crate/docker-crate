#!/bin/bash


if [[ -z "$1" ]]; then
    echo "update.sh <version>"
    exit 1
else
    VERSION=$1
fi

VERSION_EXISTS=$(curl -f -XHEAD --head https://cdn.crate.io/downloads/releases/crate-${VERSION}.tar.gz)

if [ "$?" != "0" ]; then
    echo "version $VERSION doesn't exist!"
    exit 1
fi

TAG_EXISTS=$(git tag | grep $VERSION)

if [ "$VERSION" == "$TAG_EXISTS" ]
then
    echo "Tag $TAG_EXISTS already in use"
    exit 1
fi

sed "s/XXX/$VERSION/g" Dockerfile.template > Dockerfile
git add Dockerfile
git commit -m "updated Dockerfile to use crate version $VERSION"

git tag $VERSION
git push
git push --tags
