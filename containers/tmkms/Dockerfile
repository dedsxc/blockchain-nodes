## Stage 1: Fetch the latest version and determine the architecture and build
FROM rust:1.78.0-buster@sha256:522a925f1d3642ae82a0079694a9051ed1c15f189842dbe4d75a1210d3a77e7e AS fetcher

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
FROM debian:stable-slim@sha256:0200978f5b28cc795ec1699254fd789263193af9ab650bd2e4ef2bedf6cbd1c2

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