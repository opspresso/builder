#!/bin/bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

SHELL_DIR=$(dirname $0)

CMD=${1:-${CIRCLE_JOB}}

USERNAME=${CIRCLE_PROJECT_USERNAME:-opspresso}
REPONAME=${CIRCLE_PROJECT_REPONAME:-builder}

BRANCH=${CIRCLE_BRANCH:-master}

BUCKET="repo.opspresso.com"

GIT_USERNAME="bot"
GIT_USEREMAIL="bot@nalbam.com"

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
    mkdir -p ${SHELL_DIR}/target/dist
    mkdir -p ${SHELL_DIR}/versions

    # 755
    find ./** | grep [.]sh | xargs chmod 755
}

_package() {
    _check_version "kubectl" "kubernetes/kubernetes"
    _check_version "helm" "helm/helm"
    _check_version "argo" "argoproj/argo"

    if [ ! -z ${CHANGED} ]; then
        _check_version "awscli" "aws/aws-cli"
        _check_version "awsauth" "kubernetes-sigs/aws-iam-authenticator" "v"

        _git_push
    else
        # _error "no updated"
        # rm -rf ${SHELL_DIR}/target
        echo "stop" > ${SHELL_DIR}/target/circleci-stop
    fi
}

_check_version() {
    NAME=${1}
    REPO=${2}
    TRIM=${3}

    touch ${SHELL_DIR}/versions/${NAME}

    NOW=$(cat ${SHELL_DIR}/versions/${NAME} | xargs)

    if [ "${NAME}" == "awscli" ]; then
        pushd ${SHELL_DIR}/target
        curl -sLO https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
        unzip awscli-bundle.zip
        popd

        NEW=$(ls ${SHELL_DIR}/target/awscli-bundle/packages/ | grep awscli | sed 's/awscli-//' | sed 's/.tar.gz//' | xargs)

        rm -rf ${SHELL_DIR}/target/awscli-*
    else
        NEW=$(curl -s https://api.github.com/repos/${REPO}/releases/latest | grep tag_name | cut -d'"' -f4 | xargs)
    fi

    if [ "${NEW}" == "" ]; then
        return
    fi

    if [ "${TRIM}" == "" ]; then
        CURR="${NEW}"
    else
        CURR=$(echo "${NEW}" | cut -d'v' -f2)
    fi

    _result "$(printf '%-25s %-25s %-25s' "${NAME}" "${NOW}" "${NEW}")"

    if [ "${NEW}" != "${NOW}" ]; then
        CHANGED=true

        printf "${NEW}" > ${SHELL_DIR}/versions/${NAME}
        printf "${NEW}" > ${SHELL_DIR}/target/dist/${NAME}

        # replace
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${CURR}/g" ${SHELL_DIR}/Dockerfile
        _replace "s/ENV ${NAME} .*/ENV ${NAME} ${CURR}/g" ${SHELL_DIR}/README.md

        # slack
        _slack "${NAME}" "${REPO}" "${NEW}"
    fi
}

_slack() {
    if [ -z ${SLACK_TOKEN} ]; then
        return
    fi

    curl -sL opspresso.com/tools/slack | bash -s -- \
        --token="${SLACK_TOKEN}" --username="${USERNAME}" \
        --footer="<https://github.com/${2}/releases/tag/${3}|${2}>" \
        --footer_icon="https://repo.opspresso.com/favicon/github.png" \
        --color="good" --title="${1} updated" "\`${3}\`"
}

_git_push() {
    if [ -z ${GITHUB_TOKEN} ]; then
        return
    fi
    if [ "${BRANCH}" != "master" ]; then
        return
    fi

    # commit log
    LIST=/tmp/versions
    ls ${SHELL_DIR}/versions | sort > ${LIST}

    echo "${REPONAME}" > ${SHELL_DIR}/target/log

    while read VAL; do
        echo "${VAL} $(cat ${SHELL_DIR}/versions/${VAL} | xargs)" >> ${SHELL_DIR}/target/log
    done < ${LIST}

    git config --global user.name "${GIT_USERNAME}"
    git config --global user.email "${GIT_USEREMAIL}"

    _command "git add --all"
    git add --all

    _command "git commit -m $(cat ${SHELL_DIR}/target/log)"
    git commit -m "$(cat ${SHELL_DIR}/target/log)"

    _command "git push github.com/${USERNAME}/${REPONAME} ${BRANCH}"
    git push -q https://${GITHUB_TOKEN}@github.com/${USERNAME}/${REPONAME}.git ${BRANCH}
}

################################################################################

_prepare

_package
