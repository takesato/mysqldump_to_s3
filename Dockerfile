FROM alpine:3.6

RUN apk --no-cache update \
 && apk --no-cache add python py-pip py-setuptools ca-certificates groff less mysql-client bash gzip curl jq \
 && pip --no-cache-dir install awscli \
 && rm -rf /var/cache/apk/* \
 && mkdir /sql

VOLUME ["/dump_temp"]
COPY entrypoint.sh ./
WORKDIR ./
ENTRYPOINT ["./entrypoint.sh"]