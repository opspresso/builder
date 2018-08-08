#!/bin/bash

NAME=${1:-sample}
BRANCH=${1:-master}

VERSION=
REVISION=$(git rev-parse --short=6 HEAD)

NODE=$(kubectl get ing -n default -o wide | grep sample-node | head -1 | awk '{print $2}')

# from api
if [ ! -z ${NODE} ]; then
    VERSION=$(curl -sL -X POST http://${NODE}/counter/${NAME} | xargs)
fi

# from local temp file
if [ -z ${VERSION} ]; then
    LIST=/home/jenkins/.version/list
    TEMP=/tmp/.version

    echo "# version" > ${TEMP}

    if [ -f ${LIST} ]; then
        while read LINE; do
            ARR=(${LINE})

            if [ "${ARR[0]}" == "#" ]; then
                continue
            fi

            if [ "${ARR[0]}" == "${NAME}" ]; then
                VER=$(( ${ARR[1]} + 1 ))
                VERSION=${VER}
            else
                VER=${ARR[1]}
            fi

            echo "${ARR[0]} ${VER}" >> ${TEMP}
        done < ${LIST}
    fi

    if [ -z ${VERSION} ]; then
        VERSION=1
        echo "${NAME} ${VERSION}" >> ${TEMP}
    fi

    cp -rf ${TEMP} ${LIST}
fi

if [ "${BRANCH}" == "master" ]; then
    printf "1.0.${VERSION}-${REVISION}" > /home/jenkins/VERSION
else
    printf "0.1.${VERSION}-${BRANCH}" > /home/jenkins/VERSION
fi

echo "# VERSION: $(cat /home/jenkins/VERSION)"
