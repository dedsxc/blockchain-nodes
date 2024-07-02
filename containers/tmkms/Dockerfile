## Stage 1: Fetch the latest version and determine the architecture and build
FROM rust:1.79.0-buster@sha256:3ccb54f58e7853d290648010f0b6cc3432590d304f419485ce022e2b18cd1b46 AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/iqlusioninc/tmkms/tags

SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt update; apt install -y curl jq git libudev-dev pkg-config build-essential

# Fetch the latest stable version
RUN LATEST_VERSION=$(curl -sX GET ${LATEST_ENDPOINT} | jq --raw-output '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1) && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info

# Build
RUN source /tmp/version_info && \
    git clone --depth 1 --branch $VERSION https://github.com/iqlusioninc/tmkms.git && \ 
    cd tmkms && \
    cp tmkms.toml.example /tmp && \
    cargo install tmkms --features="ledger,yubihsm,softsign" --root /tmp
    

## Stage 2: Install node
# See: https://docs.osmosis.zone/osmosis-core/keys/tmkms/
FROM debian:stable-slim@sha256:f8bbfa052db81e5b8ac12e4a1d8310a85d1509d4d0d5579148059c0e8b717d4e

ENV HOME=/data

# Setup directory and user
RUN apt update && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/bin/tmkms /usr/bin/tmkms
COPY entrypoint.sh /usr/bin/entrypoint.sh
    

# # # Setup permission
RUN chown -R user:user ${HOME} /tmp

WORKDIR ${HOME}

USER user

ENTRYPOINT [ "entrypoint.sh"]