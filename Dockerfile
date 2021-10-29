FROM alpine:3.14 as build-stage

ARG RSYNC_VERSION=3.2.3

RUN apk add --no-cache \
    build-base \
    lz4-dev \
    openssl-dev \
    xxhash-dev \
    zstd-dev

RUN wget https://download.samba.org/pub/rsync/src/rsync-${RSYNC_VERSION}.tar.gz
RUN tar -xzf rsync-${RSYNC_VERSION}.tar.gz
WORKDIR /rsync-${RSYNC_VERSION}
RUN ./configure --prefix=/usr
RUN make -j $(nproc)
RUN make install

FROM alpine:3.14

RUN apk add --no-cache \
    libxxhash \
    lz4-libs \
    zstd-libs

COPY --from=build-stage /usr/bin/rsync /usr/bin/rsync
COPY --from=build-stage /usr/bin/rsync-ssl /usr/bin/rsync-ssl

COPY entrypoint.sh /entrypoint.sh
RUN chmod 744 /entrypoint.sh

EXPOSE 873
CMD ["rsyncd"]
ENTRYPOINT ["/entrypoint.sh"]
