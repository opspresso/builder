#!/bin/bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

SHELL_DIR=$(dirname $0)

REPOSITORY=${GITHUB_REPOSITORY}

USERNAME=${GITHUB_ACTOR}
REPONAME=$(echo "${REPOSITORY}" | cut -d'/' -f2)

################################################################################

# command -v tput > /dev/null && TPUT=true
TPUT=

_echo() {
    if [ "${TPUT}" != "" ] && [ "$2" != "" ]; then
        echo -e "$(tput setaf $2)$1$(tput sgr0)"
    else
        echo -e "$1"
    fi
}

_result() {
    echo
    _echo "# $@" 4
}

_command() {
    echo
    _echo "$ $@" 3
}

_success() {
    echo
    _echo "+ $@" 2
    exit 0
}

_error() {
    echo
    _echo "- $@" 1
    exit 1
}

_replace() {
    if [ "${OS_NAME}" == "darwin" ]; then
        sed -i "" -e "$1" $2
    else
        sed -i -e "$1" $2
    fi
}

_prepare() {
    # target
    mkdir -p ${SHELL_DIR}/target/publish
    mkdir -p ${SHELL_DIR}/target/release

    # 755
    find ${SHELL_DIR}/** | grep [.]sh | xargs chmod 755
}

################################################################################

_package() {
    _check_version "argo" "argoproj/argo"
    _check_version "helm" "helm/helm"
    _check_version "kubectl" "kubernetes/kubernetes"

    if [ ! -z ${CHANGED} ]; then
        _check_version "awscli" "aws/aws-cli"

        # _check_version "awsauth" "kubernetes-sigs/aws-iam-authenticator" "v"
        # _check_version "hub" "github/hub" "v"
    fi
}

_check_version() {
    NAME=${1}
    REPO=${2}
    TRIM=${3}

    NOW=$(cat ${SHELL_DIR}/Dockerfile | grep "ENV ${NAME}" | awk '{print $3}' | xargs)

    NEW=$(curl -sL repo.opspresso.com/latest/${REPO} | xargs)

    if [ "${NEW}" == "" ]; then
        return
    fi

    _result "$(printf '%-25s %-25s %-25s' "${NAME}" "${NOW}" "${NEW}")"

    if [ "${NEW}" != "${NOW}" ]; then
        CHANGED=true

        # replace
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/Dockerfile
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/README.md
    fi
}

################################################################################

_prepare

_package
