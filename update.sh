#!/bin/bash -x

if [[ -z "$1" || -z "$2" ]]; then
    echo "update.sh <version> <template>"
    exit 1
else
    TAG="$1"
    TEMPLATE="$2.template"
    VERSION=`echo $TAG | cut -d '-' -f 1`
fi

VERSION_EXISTS=$(curl -fsSI https://cdn.crate.io/downloads/releases/crate-${VERSION}.tar.gz)

if [ "$?" != "0" ]; then
    echo "version $VERSION doesn't exist!"
    exit 1
fi

TAG_EXISTS=$(git tag | grep $TAG)

if [ "$TAG" == "$TAG_EXISTS" ]; then
    echo "Tag $TAG_EXISTS already in use"
    exit 1
fi

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Template $TEMPLATE does not exist"
    exit 1
fi

exit 0
sed "s/XXX/$VERSION/g" "$TEMPLATE" > Dockerfile
