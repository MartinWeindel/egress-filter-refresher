# SPDX-FileCopyrightText: 2022 SAP SE or an SAP affiliate company and Gardener contributors
#
# SPDX-License-Identifier: Apache-2.0

############# gobuilder
FROM golang:1.21.3 AS gobuilder

WORKDIR /build
COPY ./VERSION ./VERSION
COPY ./.git ./.git
COPY . .
ARG TARGETARCH
RUN make build-filter-updater GOARCH=$TARGETARCH

FROM alpine:3.17.3 as builder

WORKDIR /volume

COPY --from=gobuilder /build/filter-updater ./filter-updater

RUN apk update; \
    apk add ipset; \
    apk add ip6tables; \
    apk add iproute2-minimal

RUN mkdir -p ./bin ./sbin ./lib ./usr/bin ./usr/sbin ./usr/lib ./usr/lib/xtables ./tmp ./run ./etc/iproute2\
    && cp -d /lib/ld-musl-* ./lib                                           && echo "package musl" \
    && cp -d /lib/libc.musl-* ./lib                                         && echo "package musl" \
    && cp -d /usr/lib/libcap.* ./usr/lib                                    && echo "package libcap" \
    && cp -d /usr/lib/libpsx.* ./usr/lib                                    && echo "package libcap" \
    && cp -d /usr/lib/libbz2* ./usr/lib                                     && echo "package libbz2" \
    && cp -d /usr/lib/libfts* ./usr/lib                                     && echo "package fts" \
    && cp -d /usr/lib/liblzma* ./usr/lib                                    && echo "package xz-libs" \
    && cp -d /lib/libz.* ./lib                                              && echo "package zlib" \
    && cp -d /usr/lib/libasm* ./usr/lib                                     && echo "package libelf" \
    && cp -d /usr/lib/libdw* ./usr/lib                                      && echo "package libelf" \
    && cp -d /usr/lib/libelf* ./usr/lib                                     && echo "package libelf" \
    && cp -d /usr/lib/libmnl.* ./usr/lib                                    && echo "package libmnl" \
    && cp -d /sbin/ip ./sbin                                                && echo "package iproute2-minimal" \
    && cp -d /etc/iproute2/* ./etc/iproute2                                 && echo "package iproute2-minimal" \
    && cp -d /usr/lib/libipset* ./usr/lib                                   && echo "package ipset" \
    && cp -d /usr/sbin/ipset* ./usr/sbin                                    && echo "package ipset" \
    && cp -d /usr/lib/libnftnl* ./usr/lib                                   && echo "package libnftnl" \
    && cp -d /etc/ethertypes ./etc                                          && echo "package iptables" \
    && cp -d /sbin/iptables* ./sbin                                         && echo "package iptables" \
    && cp -d /sbin/xtables* ./sbin                                          && echo "package iptables" \
    && cp -d /usr/lib/libip4* ./usr/lib                                     && echo "package iptables" \
    && cp -d /usr/lib/libip6* ./usr/lib                                     && echo "package iptables" \
    && cp -d /usr/lib/libipq* ./usr/lib                                     && echo "package iptables" \
    && cp -d /usr/lib/libxtables* ./usr/lib                                 && echo "package iptables" \
    && cp -d /usr/lib/xtables/* ./usr/lib/xtables                           && echo "package iptables" \
    && cp -d /sbin/ip6tables* ./sbin                                        && echo "package ip6tables"

FROM scratch

COPY --from=builder /volume /

CMD /filter-updater
