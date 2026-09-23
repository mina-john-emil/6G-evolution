
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3-pip python3-setuptools python3-wheel ninja-build build-essential \
    flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev \
    libidn-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev \
    libmicrohttpd-dev libcurl4-gnutls-dev libtins-dev \
    libtalloc-dev meson cmake wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /open5gs
COPY . /open5gs

RUN meson build --prefix=`pwd`/install && ninja -C build && ninja -C build install


FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3.10 python3-pip python3-setuptools python3-wheel \
    libsctp1 libgnutls30 libgcrypt20 libssl3 libidn12 \
    libmongoc-1.0-0 libbson-1.0-0 libyaml-0-2 libnghttp2-14 \
    libmicrohttpd12 libcurl3-gnutls libtins4.0 libtalloc2 iproute2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /open5gs/install /usr/local
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/open5gs.conf && ldconfig

RUN mkdir -p /etc/open5gs /var/log/open5gs /etc/open5gs/tls /etc/open5gs/hnet

VOLUME [ "/etc/open5gs" ]
VOLUME [ "/var/log/open5gs" ]

EXPOSE 7777 38412 2152 9090
