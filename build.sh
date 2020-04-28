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

    # messAge
    echo "$(date +%Y%m%d-%H%M)" > ./target/commit_message
}

################################################################################

_package() {
    _check_version "helm"
    _check_version "kubectl"

    if [ -z "${CHANGED}" ]; then
        _error "Not changed"
    fi

    _check_version "awscli"
}

_check_version() {
    NAME=${1}

    NOW=$(cat ${SHELL_DIR}/README.md | grep "ENV ${NAME}" | awk '{print $3}' | xargs)

    NEW=$(curl -sL repo.opspresso.com/latest/${NAME} | xargs)

    if [ -z "${NEW}" ]; then
        return
    fi

    _result "$(printf '%-30s %-25s %-25s' "${NAME}" "${NOW}" "${NEW}")"

    echo "${NAME} ${NEW}" >> ./target/commit_message

    if [ "${NOW}" != "${NEW}" ]; then
        CHANGED=true

        # replace
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/README.md
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/Dockerfile
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/VERSIONS
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/alpine/Dockerfile
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${NEW}/g" ${SHELL_DIR}/kube/Dockerfile
    fi
}

################################################################################

_prepare

_package
