# Dockerfile

FROM docker

RUN apk add -v --update bash curl python py-pip jq git

ENV kubectl v1.15.4
ENV awscli 1.16.210
ENV helm v2.14.3

RUN pip install --upgrade awscli==${awscli} && \
    apk del -v --purge py-pip && \
    rm /var/cache/apk/*

# kubectl
RUN curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# aws-iam-authenticator
RUN curl -sLo /bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /bin/aws-iam-authenticator

# helm
RUN curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

COPY .m2/ /root/.m2/

ENTRYPOINT ["bash"]
