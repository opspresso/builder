# Dockerfile

FROM docker

RUN apk add -v --update python3 python3-dev bash curl git jq perl openssh busybox-extras

ENV argo v2.3.0
ENV awsauth 0.3.0
ENV awscli 1.16.154
ENV helm v2.14.1
ENV hub 2.11.2
ENV kubectl v1.12.9

RUN pip3 install --upgrade awscli==${awscli} && \
    rm /var/cache/apk/*

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    chmod +x linux-amd64/helm && mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sLO https://github.com/argoproj/argo/releases/download/${argo}/argo-linux-amd64 && \
    chmod +x argo-linux-amd64 && mv argo-linux-amd64 /usr/local/bin/argo

RUN curl -sLO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${awsauth}/heptio-authenticator-aws_${awsauth}_linux_amd64 && \
    chmod +x heptio-authenticator-aws_${awsauth}_linux_amd64 && mv heptio-authenticator-aws_${awsauth}_linux_amd64 /usr/local/bin/aws-iam-authenticator

RUN curl -sL https://github.com/github/hub/releases/download/v${hub}/hub-linux-amd64-${hub}.tgz | tar xz && \
    chmod +x hub-linux-amd64-${hub}/bin/hub && mv hub-linux-amd64-${hub}/bin/hub /usr/local/bin/hub && \
    chown -R root:root /usr/local/bin/hub

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
