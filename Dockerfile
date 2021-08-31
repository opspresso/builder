# Dockerfile

FROM docker

RUN apk --no-cache update && \
    apk add --no-cache bash curl python3 py3-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# awscli
# ENV awscli 2.2.30
RUN pip3 --no-cache-dir install awscli

# buildx
ENV buildx v0.5.1
RUN curl -sL -o /usr/lib/docker/cli-plugins/docker-buildx \
      "https://github.com/docker/buildx/releases/download/v${buildx}/buildx-v${buildx}.linux-amd64" && \
    chmod a+x /usr/lib/docker/cli-plugins/docker-buildx

COPY .m2/ /root/.m2/

VOLUME /root/.aws

ENTRYPOINT ["bash"]
