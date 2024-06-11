## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/node-real/bsc-erigon/releases/latest

SHELL ["/bin/bash", "-c"]

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
RUN source /tmp/version_info && \
    wget -O /tmp/bsc-erigon.tar.gz https://github.com/node-real/bsc-erigon/releases/download/v${VERSION}/bsc-erigon_${VERSION}_linux_${ARCH}.tar.gz && \
    tar xzvf /tmp/bsc-erigon.tar.gz -C /tmp/

## Stage 2: Install node
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd

ENV HOME=/app

# Install
RUN apt update && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/erigon /usr/bin/erigon

# Setup permission
RUN chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

EXPOSE 8545 \
    8551 \
    8546 \
    30303 \
    30303/udp \
    42069 \
    42069/udp \
    8080 \
    9090 \
    6060

CMD [ "erigon"]