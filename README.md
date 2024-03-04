# Node-FIPS

## What is this?

This repo builds a docker image that loads the OpenSSL FIPS provider into the `node:lts-alpine` image.
A OpenSSL configuration file is included and setup so when `node -p 'crypto.getFips()'` is executed it will return 1 by default.

The FIPS provider is built using OpenSSL 3.0.9.
