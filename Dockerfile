# Dockerfile

FROM docker

RUN apk --no-cache update && \
    apk add --no-cache bash curl python3 py3-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# awscli
ENV awscli 1.18.43
RUN pip install --upgrade awscli==${awscli} && \
    apk del -v --purge py-pip && \
    rm /var/cache/apk/*

# buildx
COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx

COPY .m2/ /root/.m2/

VOLUME /root/.aws

ENTRYPOINT ["bash"]
