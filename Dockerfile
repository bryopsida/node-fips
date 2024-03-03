FROM alpine:3 AS builder
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
COPY --from=builder node-v*/out/Release/node /bin/node