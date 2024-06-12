## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd AS fetcher

SHELL ["/bin/bash", "-c"]

ENV LATEST_ENDPOINT=https://api.github.com/repos/cosmos/gaia/releases/latest

# Install necessary packages
RUN apt update; apt install -y curl jq wget

# Fetch the latest version and set architecture
RUN LATEST_VERSION=$(curl -sX GET $LATEST_ENDPOINT | jq --raw-output '.tag_name' | sed 's/^v//') && \
    UNAME_ARCH=$(uname -m) && \
    if [ "$UNAME_ARCH" = "x86_64" ]; then ARCH="amd64"; \
    elif [ "$UNAME_ARCH" = "aarch64" ]; then ARCH="arm64"; \
    else echo "Unsupported architecture: $UNAME_ARCH" && exit 1; fi && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info && \
    echo "ARCH=$ARCH" >> /tmp/version_info

# Source the version and architecture info and download node
# https://github.com/cosmos/gaia/releases/download/v17.2.0/gaiad-v17.2.0-linux-amd64
RUN source /tmp/version_info && \
    wget -O /tmp/gaiad https://github.com/cosmos/gaia/releases/download/v${VERSION}/gaiad-v${VERSION}-linux-${ARCH} && \
    chmod +x /tmp/gaiad

## Stage 2: Install node
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd

# Define CONFIG_DIR as env variable to be used in entrypoint.sh
ENV CONFIG_DIR=/data
ENV HOME=/app

# Install wget
RUN apt update; apt install -y wget lz4 libxml2-utils && \
    mkdir ${HOME} ${CONFIG_DIR} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/gaiad /usr/bin/gaiad
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Setup permission
RUN chown -R user:user ${HOME} ${CONFIG_DIR}

WORKDIR ${HOME}

USER user

EXPOSE 1317 \
    26660 \
    26656 \
    26657

ENTRYPOINT [ "entrypoint.sh"]

