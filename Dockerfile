# Dockerfile

FROM docker

RUN apk add -v --update python py-pip bash curl git jq openssh

ENV awscli 1.15.85
ENV toaster v0.0.27
ENV kubectl v1.11.2
ENV helm v2.10.0
ENV draft v0.15.0

RUN pip install --upgrade awscli==${awscli} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

RUN curl -sLO https://github.com/nalbam/toaster/releases/download/${toaster}/toaster && \
    chmod +x toaster && mv toaster /usr/local/bin/toaster

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sL https://azuredraft.blob.core.windows.net/draft/draft-${draft}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/draft /usr/local/bin/draft

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
