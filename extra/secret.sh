#!/bin/bash

NAME=${1:-"sample"}
TYPE=${2:-"ssh-privatekey"}
DIST=${3:-"/root/.ssh/id_rsa"}
NAMESPACE=${4:-"devops"}

mkdir -p /root/.ssh

# echo "Host *" > /root/.ssh/config
# echo "    StrictHostKeyChecking no" >> /root/.ssh/config

SECRET=$(kubectl get secret ${NAME} -n ${NAMESPACE} -o json | jq '.data."${TYPE}"' --raw-output)

if [ ! -z ${SECRET} ]; then
    echo "${SECRET}" | base64 --decode > ${DIST}
    chmod 600 ${DIST}
fi

# echo "" > /root/.ssh/known_hosts
