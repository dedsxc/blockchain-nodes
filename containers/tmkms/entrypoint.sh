#!/bin/bash

CONFIG_DIR=$HOME

if [ -z "$NETWORKS" ]; then
  # If NETWORKS is not set, set it to the default value
  NETWORKS="cosmoshub"
fi

# if config dir not exist, init config
if [ ! -d "$CONFIG_DIR/config" ] || [ -z "$(ls -A $CONFIG_DIR/config)" ]; then
    echo -e "\e[32m[+]\e[0m Init config"
    tmkms init --networks $NETWORKS config

    echo -e "\e[32m[+]\e[0m Generate key pair"
    tmkms softsign keygen ./config/secrets/secret_connection_key
fi

SECRETS_DIR=/tmp/secrets
# Copy validator keys 
if [ -d "$SECRETS_DIR" ]; then
    for key_file in $(find $SECRETS_DIR -type f -printf '%f\n'); do
        echo -e "\e[32m[+]\e[0m Import validator key '$key_file' into tmkms"
        tmkms softsign import "$SECRETS_DIR/$key_file" "$HOME/config/secrets/${key_file%.*}"
        # remove the key file after import
        rm "$SECRETS_DIR/$key_file"
    done
fi

# Copy custom config
if [ -f "/tmp/config/tmkms.toml" ]; then
    # Provide validator ip:port to connect
    echo -e "\e[32m[+]\e[0m Copy custom tmkms.toml"
    cp /tmp/config/tmkms.toml $CONFIG_DIR/config/tmkms.toml
else
    echo -e "\e[91m[-]\e[0m We recommend import your own tmkms.toml. We will use default tmkms.toml instead."
fi

# Start
echo -e "\e[32m[+]\e[0m Start tmkms..."
tmkms start -c $CONFIG_DIR/config/tmkms.toml