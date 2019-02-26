# Dockerfile

FROM docker

RUN apk add -v --update python py-pip bash curl git jq openssh perl busybox-extras

ENV awscli 1.16.112
ENV kubectl v1.13.3
ENV helm v2.12.3

RUN pip install --upgrade awscli==${awscli} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

COPY slack.sh /usr/local/bin/slack

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
