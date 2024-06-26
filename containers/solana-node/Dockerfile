## Stage 1: Fetch the latest version and determine the architecture and build
FROM debian:stable-slim@sha256:0200978f5b28cc795ec1699254fd789263193af9ab650bd2e4ef2bedf6cbd1c2 AS fetcher

ENV LATEST_ENDPOINT=https://api.github.com/repos/solana-labs/solana/releases/latest
ENV RELEASE_ENDPOINT=https://github.com/solana-labs/solana/releases/download

SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt update; apt install -y curl jq wget bzip2

# Fetch the latest version and set architecture
RUN LATEST_VERSION=$(curl -sX GET ${LATEST_ENDPOINT} | jq --raw-output '.tag_name' | sed 's/^v//') && \
    UNAME_ARCH=$(uname -m) && \
    if [ "$UNAME_ARCH" = "x86_64" ]; then ARCH="x86_64"; \
    elif [ "$UNAME_ARCH" = "aarch64" ]; then ARCH="aarch64"; \
    else echo "Unsupported architecture: $UNAME_ARCH" && exit 1; fi && \
    echo "VERSION=$LATEST_VERSION" > /tmp/version_info && \
    echo "ARCH=$ARCH" >> /tmp/version_info

# Build solana
RUN source /tmp/version_info && \
    wget -O /tmp/solana.tar.bz2 ${RELEASE_ENDPOINT}/v${VERSION}/solana-release-${ARCH}-unknown-linux-gnu.tar.bz2 && \
    tar xjvf /tmp/solana.tar.bz2 -C /tmp && \
    rm /tmp/solana.tar.bz2 

## Stage 2: Install node
FROM debian:stable-slim@sha256:0200978f5b28cc795ec1699254fd789263193af9ab650bd2e4ef2bedf6cbd1c2

ENV HOME=/data

# Setup directory and user
RUN apt update && \
    mkdir ${HOME} && \
    adduser user

# Copy the version and architecture info from the fetcher stage
COPY --from=fetcher /tmp/version_info /tmp/version_info
COPY --from=fetcher /tmp/solana-release/bin/solana /usr/bin/solana
COPY --from=fetcher /tmp/solana-release/bin/solana-keygen /usr/bin/solana-keygen
COPY --from=fetcher /tmp/solana-release/bin/solana-validator /usr/bin/solana-validator
COPY --from=fetcher /tmp/solana-release/bin/solana-test-validator /usr/bin/solana-test-validator
    

# Setup permission
RUN chown -R user:user ${HOME}

WORKDIR ${HOME}

USER user

# https://docs.solanalabs.com/operations/requirements#networking
EXPOSE 8899 \
    8900 \ 
    8000-10000/tcp \
    8000-10000/udp

CMD [ "solana-validator"]