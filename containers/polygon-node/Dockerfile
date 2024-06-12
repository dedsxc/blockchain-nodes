## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/maticnetwork/heimdall/releases/latest

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

## Stage 2: Install node
FROM debian:stable-slim@sha256:2b2e35d67c8fda0ba853d40cd18e57b99ab12d82fd3200607015eb09784068bd

SHELL ["/bin/bash", "-c"]

ENV HOME=/data

# Install wget
## pv, aria2 is needed for downloading snapshot and zstd to extract
RUN apt update; apt install -y wget curl sudo pv aria2 zstd && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY entrypoint.sh /usr/bin

# Source the version and architecture info and download node
RUN source /tmp/version_info && \
    wget -O heimdalld.deb https://github.com/maticnetwork/heimdall/releases/download/v${VERSION}/heimdalld-v${VERSION}-${ARCH}.deb && \
    dpkg -i heimdalld.deb && rm heimdalld.deb && \
    rm -rf /var/lib/apt/lists/*

# Setup permission
RUN chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

EXPOSE 1317 \
    26656 \
    26660

ENTRYPOINT [ "entrypoint.sh"]

