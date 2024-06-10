#!/bin/bash

HOME=$CONFIG_DIR
MONIKER=cosmos-4

if [ ! -d "$HOME/data" ] || [ -z "$(ls -A $HOME/data)" ]; then
    # Init
    echo -e "\e[32m[+]\e[0m Init config"
    gaiad init $MONIKER --home $HOME

    # Download genesis file
    echo -e "\e[32m[+]\e[0m Download genesis file"
    wget -nv https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
    gzip -d genesis.cosmoshub-4.json.gz
    mv genesis.cosmoshub-4.json $HOME/config/genesis.json

    # Configure seeds and peers
    echo -e "\e[32m[+]\e[0m Setup addrbook.json"
    wget -nv -O $HOME/config/addrbook.json https://dl2.quicksync.io/json/addrbook.cosmos.json

    # Configure gas price
    echo -e "\e[32m[+]\e[0m Setup minimum gas price"
    sed -i 's|^minimum-gas-prices =.*|minimum-gas-prices = "0.0025uatom"|g' $HOME/config/app.toml

    # Configure pruning of state
    ## see: https://github.com/cosmos/gaia/blob/main/docs/docs/hub-tutorials/join-mainnet.md#pruning-of-state
    sed -i 's|^pruning =.*|pruning = "default"|g' $HOME/config/app.toml

    # Enable prometheus
    echo -e "\e[32m[+]\e[0m Enable prometheus monitoring"
    sed -i 's|^prometheus =.*|prometheus = "true"|g' $HOME/config/config.toml
    sed -i 's|^max_open_connections =.*|max_open_connections = 100|g' $HOME/config/config.toml

    # Download pruned snapshot
    # Or check in https://polkachu.com/tendermint_snapshots/cosmos for 15Gi snapshot
    echo -e "\e[32m[+]\e[0m Downloading snapshot"
    wget -nv -O cosmos.tar.lz4 https://snapshots.polkachu.com/snapshots/cosmos/cosmos_20801917.tar.lz4 
    lz4 -d cosmos.tar.lz4
    tar -xf cosmos.tar -C $HOME/config/data --strip-components=1
fi

# Start
echo -e "\e[32m[+]\e[0m Start gaia ..."
gaiad start --home $HOME 