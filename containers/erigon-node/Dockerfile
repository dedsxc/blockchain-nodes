## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd AS fetcher

ENV RELEASE_ENDPOINT=https://api.github.com/repos/ledgerwatch/erigon/releases/latest

# Install necessary packages
RUN apt update; apt install -y curl jq

# Fetch the latest version and set architecture
RUN LATEST_VERSION=$(curl -sX GET $RELEASE_ENDPOINT | jq --raw-output '.tag_name' | sed 's/^v//') && \
    UNAME_ARCH=$(uname -m) && \
    if [ "$UNAME_ARCH" = "x86_64" ]; then ARCH="amd64"; \
    elif [ "$UNAME_ARCH" = "aarch64" ]; then ARCH="arm64"; \
    else echo "Unsupported architecture: $UNAME_ARCH" && exit 1; fi && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info && \
    echo "ARCH=$ARCH" >> /tmp/version_info

## Stage 2: Download Erigon tarball using the fetched version and architecture
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd

SHELL ["/bin/bash", "-c"]
ENV HOME=/app

# Install wget
RUN apt update; apt install -y wget && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info

# Source the version and architecture info and download Erigon
RUN source /tmp/version_info && \
    wget -O /tmp/erigon.tar.gz https://github.com/ledgerwatch/erigon/releases/download/v${VERSION}/erigon_${VERSION}_linux_${ARCH}.tar.gz && \
    tar xzvf /tmp/erigon.tar.gz -C ${HOME} && \
    rm /tmp/erigon.tar.gz

# Setup permission
RUN chmod +x ${HOME}/erigon && \
    chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

EXPOSE 8545 6060

CMD [ "/app/erigon" ]