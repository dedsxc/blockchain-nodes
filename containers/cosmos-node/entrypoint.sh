#!/bin/bash

MONIKER=cosmos-4

if [ ! -d "$CONFIG_DIR/data" ] || [ -z "$(ls -A $CONFIG_DIR/data)" ]; then
    # Init
    echo -e "\e[32m[+]\e[0m Init config"
    gaiad init $MONIKER --home $CONFIG_DIR

    # Download genesis file
    echo -e "\e[32m[+]\e[0m Download genesis file"
    wget -nv https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
    gzip -d genesis.cosmoshub-4.json.gz
    mv genesis.cosmoshub-4.json $CONFIG_DIR/config/genesis.json

    # Configure seeds and peers
    echo -e "\e[32m[+]\e[0m Setup addrbook.json"
    wget -nv -O $CONFIG_DIR/config/addrbook.json https://dl2.quicksync.io/json/addrbook.cosmos.json

    # Configure gas price
    echo -e "\e[32m[+]\e[0m Setup minimum gas price"
    sed -i 's|^minimum-gas-prices =.*|minimum-gas-prices = "0.0025uatom"|g' $CONFIG_DIR/config/app.toml

    # Configure pruning of state
    ## see: https://github.com/cosmos/gaia/blob/main/docs/docs/hub-tutorials/join-mainnet.md#pruning-of-state
    sed -i 's|^pruning =.*|pruning = "default"|g' $CONFIG_DIR/config/app.toml

    # Enable prometheus
    echo -e "\e[32m[+]\e[0m Enable prometheus monitoring"
    sed -i 's|^prometheus =.*|prometheus = "true"|g' $CONFIG_DIR/config/config.toml
    sed -i 's|^max_open_connections =.*|max_open_connections = 100|g' $CONFIG_DIR/config/config.toml

    # Download polkachu snapshot
    # check in https://polkachu.com/tendermint_snapshots/cosmos for 15Gi snapshot
    latest_snapshot=$(wget -qO- https://snapshots.polkachu.com/snapshots/ | xmllint --format - | grep '<Key>' | grep 'cosmos' | sed -e 's|.*<Key>cosmos/\(.*\)</Key>.*|\1|' | tail -n 1)
    echo -e "\e[32m[+]\e[0m Downloading snapshot $latest_snapshot"
    wget -nv -O cosmos.tar.lz4 https://snapshots.polkachu.com/snapshots/cosmos/$latest_snapshot
    
    # Extracting archive
    echo -e "\e[32m[+]\e[0m Extracting archive"
    lz4 -qd -c cosmos.tar.lz4 > cosmos.tar
    tar -xf cosmos.tar -C $CONFIG_DIR/data --strip-components=1
    rm -rf cosmos.tar.lz4 cosmos.tar
fi

# Copy priv_validator_key 
if [ -f "/tmp/config/priv_validator_key.json" ]; then
    echo -e "\e[90m[+]\e[0m Copy priv_validator_key.json"
    cp /tmp/config/priv_validator_key.json $CONFIG_DIR/config/priv_validator_key.json
fi

# Copy custom config
if [ -f "/tmp/config/app.toml" ]; then
    echo -e "\e[90m[+]\e[0m Copy custom app.toml"
    cp /tmp/config/app.toml $CONFIG_DIR/config/app.toml
fi

if [ -f "/tmp/config/config.toml" ]; then
    echo -e "\e[90m[+]\e[0m Copy custom config.toml"
    cp /tmp/config/config.toml $CONFIG_DIR/config/config.toml
fi


# Start
echo -e "\e[32m[+]\e[0m Start gaia ..."
gaiad start --home $CONFIG_DIR 