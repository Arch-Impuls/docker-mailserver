#!/bin/sh

VERSION="${1}"
COMPONENTS="mda mta db filter ssl virus web"

if [ "${VERSION}" = "" ]
then
    echo "Expected version string!"

    exit 1
fi

docker tag archimpuls/mailserver:latest archimpuls/mailserver:${VERSION}
    
if [ "${VERSION}" != "next" ]
then
    docker push archimpuls/mailserver:latest
fi

docker push archimpuls/mailserver:${VERSION}
