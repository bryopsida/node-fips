FROM alpine:3 AS fips_builder
ARG OPENSSL_VERSION=3.0.9
RUN apk add --no-cache --virtual .build-deps \
    make gcc libgcc musl-dev linux-headers perl vim \
    &&  wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -xf openssl-${OPENSSL_VERSION}.tar.gz\
    && cd openssl-${OPENSSL_VERSION} \
    && ./Configure enable-fips --libdir=lib --prefix=/usr \
    && make \
    && make install_fips

FROM node:lts-alpine
COPY --from=fips_builder /usr/lib/ossl-modules/fips.so /usr/lib/ossl-modules/fips.so
COPY --from=fips_builder /usr/ssl/fipsmodule.cnf /usr/ssl/fipsmodule.cnf
COPY openssl.cnf /usr/ssl/openssl.cnf
ENV OPENSSL_CONF=/usr/ssl/openssl.cnf
ENV OPENSSL_MODULES=/usr/lib/ossl-modules/
