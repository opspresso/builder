# Dockerfile

FROM docker

RUN apk add -v --update bash curl python py-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# awscli
ENV awscli 1.16.298
RUN pip install --upgrade awscli==${awscli} && \
    apk del -v --purge py-pip && \
    rm /var/cache/apk/*

# kubectl
ENV kubectl v1.16.3
RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# helm
ENV helm v3.0.1
RUN curl -sL https://get.helm.sh/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# aws-iam-authenticator
RUN curl -sLo /bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /bin/aws-iam-authenticator

COPY .m2/ /root/.m2/

VOLUME /root/.aws
VOLUME /root/.kube
VOLUME /root/.helm

ENTRYPOINT ["bash"]
