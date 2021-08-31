# Dockerfile

FROM alpine

RUN apk --no-cache update && \
    apk add --no-cache bash curl python3 py3-pip jq git file tar && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub

COPY .m2/ /root/.m2/

VOLUME /root/.aws

ENTRYPOINT ["bash"]
