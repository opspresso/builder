# Dockerfile

FROM alpine

RUN apk add -v --update bash curl python3 py3-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

# awscli
ENV awscli 2.2.30
RUN pip3 install --upgrade awscli==${awscli} && \
    apk del -v --purge py3-pip && \
    rm /var/cache/apk/*

COPY .m2/ /root/.m2/

VOLUME /root/.aws

ENTRYPOINT ["bash"]
