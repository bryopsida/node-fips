FROM alpine:3 AS fips_builder
ARG OPENSSL_VERSION=3.0.13
RUN apk add --no-cache --virtual .build-deps \
    make gcc libgcc musl-dev linux-headers perl vim \
    &&  wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -xf openssl-${OPENSSL_VERSION}.tar.gz\
    && cd openssl-${OPENSSL_VERSION} \
    && ./Configure enable-fips --libdir=lib --prefix=/usr \
    && make \
    && make install_fips \
    && apk del .build-deps \
    && rm -rf openssl-${OPENSSL_VERSION}.tar.gz openssl-${OPENSSL_VERSION}

FROM alpine:3 AS node_builder
ARG NODE_VERSION=v20.11.1
ENV NODE_VERSION=${NODE_VERSION}
ENV CONFIG_FLAGS='--fully-static --without-npm --without-inspector --without-intl --enable-lto'

RUN echo "$NODE_VERSION" \
  && wget "https://nodejs.org/download/release/$NODE_VERSION/node-$NODE_VERSION.tar.xz" \
  && apk add --no-cache \
        libstdc++ \
  && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
    && tar -xf "node-$NODE_VERSION.tar.xz" \
    && cd "node-$NODE_VERSION" \
    && export CXXFLAGS="-O3 -ffunction-sections -fdata-sections" \
    && export LDFLAGS="-Wl,--gc-sections,--strip-all" \
    && ./configure ${CONFIG_FLAGS} \
    && make -j$(getconf _NPROCESSORS_ONLN) V=

FROM scratch
COPY --from=node_builder node-v*/out/Release/node /bin/node
ENV OPENSSL_CONF=/etc/nodejs.cnf
ENV OPENSSL_MODULES=/var/lib/ossl-modules/
RUN echo 'node:x:10001:10001:Linux User,,,:/home/node:/bin/sh' > /etc/passwd
USER node