# Dockerfile

FROM docker

RUN apk add -v --update bash curl python py-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# awscli
ENV awscli 2.2.30
RUN pip install --upgrade awscli==${awscli} && \
    apk del -v --purge py-pip && \
    rm /var/cache/apk/*

# buildx
ENV buildx v0.5.1
RUN curl -sL -o /usr/lib/docker/cli-plugins/docker-buildx \
  "https://github.com/docker/buildx/releases/download/v${buildx}/buildx-v${buildx}.linux-amd64"
RUN chmod a+x /usr/lib/docker/cli-plugins/docker-buildx

COPY .m2/ /root/.m2/

VOLUME /root/.aws

ENTRYPOINT ["bash"]
