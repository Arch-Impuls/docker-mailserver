#!/bin/sh

VERSION="${1}"
COMPONENTS="mda mta db filter ssl virus web"

if [ "${VERSION}" = "" ]
then
    echo "Expected version string!"

    exit 1
fi

for component in $COMPONENTS
do
    docker tag archimpuls/mailserver:$component-latest archimpuls/mailserver:$component-${VERSION}
    
    if [ "${VERSION}" != "next" ]
    then
        docker push archimpuls/mailserver:$component-latest
    fi
    
    docker push archimpuls/mailserver:$component-${VERSION}
done
