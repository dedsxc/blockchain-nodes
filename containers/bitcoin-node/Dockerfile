## Stage 1: Fetch the latest version and determine the architecture
FROM debian:stable-slim@sha256:f8bbfa052db81e5b8ac12e4a1d8310a85d1509d4d0d5579148059c0e8b717d4e AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/bitcoin/bitcoin/releases/latest

SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt update; apt install -y curl jq wget

# Fetch the latest version and set architecture
RUN LATEST_VERSION=$(curl -sX GET $LATEST_ENDPOINT | jq --raw-output '.tag_name' | sed 's/^v//') && \
    UNAME_ARCH=$(uname -m) && \
    if [ "$UNAME_ARCH" = "x86_64" ]; then ARCH="x86_64"; \
    elif [ "$UNAME_ARCH" = "aarch64" ]; then ARCH="aarch64"; \
    else echo "Unsupported architecture: $UNAME_ARCH" && exit 1; fi && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info && \
    echo "ARCH=$ARCH" >> /tmp/version_info

# Source the version and architecture info and download node
RUN source /tmp/version_info && \
    wget -O /tmp/bitcoin-core.tar.gz https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz && \
    tar xzvf /tmp/bitcoin-core.tar.gz -C /tmp/ && \
    mv /tmp/bitcoin-${VERSION}/bin/* /tmp/

## Stage 2: Install node
FROM debian:stable-slim@sha256:f8bbfa052db81e5b8ac12e4a1d8310a85d1509d4d0d5579148059c0e8b717d4e

ENV HOME=/data

# Install wget
RUN apt update && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/bitcoin-cli /usr/bin/bitcoin-cli
COPY --from=fetcher /tmp/bitcoin-qt /usr/bin/bitcoin-qt
COPY --from=fetcher /tmp/bitcoin-tx /usr/bin/bitcoin-tx
COPY --from=fetcher /tmp/bitcoin-util /usr/bin/bitcoin-util
COPY --from=fetcher /tmp/bitcoin-wallet /usr/bin/bitcoin-wallet
COPY --from=fetcher /tmp/bitcoind /usr/bin/bitcoind
COPY --from=fetcher /tmp/test_bitcoin /usr/bin/test_bitcoin

# Setup permission
RUN chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

EXPOSE 9999

CMD [ "bitcoind"]