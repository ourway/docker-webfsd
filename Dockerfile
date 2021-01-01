FROM alpine:latest as builder 


RUN apk  --virtual mypacks add --no-cache g++ git make

RUN apk update && \
    apk add mailcap && \
    rm /var/cache/apk/*

WORKDIR /compile
RUN git clone https://github.com/ourway/webfsd.git
WORKDIR /compile/webfsd
RUN make
RUN apk del mypacks

RUN cp webfsd /usr/bin/webfsd
RUN rm -rf /compile


FROM alpine:latest as prod

COPY --from=builder /usr/bin/webfsd /usr/bin/webfsd
COPY --from=builder /etc/mime.types /etc/mime.types
WORKDIR /storage

EXPOSE 8000
ENTRYPOINT ["webfsd", "-L", "-", "-F"]
