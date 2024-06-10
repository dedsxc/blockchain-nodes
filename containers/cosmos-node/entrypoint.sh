#!/bin/bash

HOME=$CONFIG_DIR
MONIKER=cosmos-4

if [ ! -d "$HOME/data" ] || [ -z "$(ls -A $HOME/data)" ]; then
    # Init
    gaiad init $MONIKER --home $HOME

    # Download genesis file
    wget -nv https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
    gzip -d genesis.cosmoshub-4.json.gz
    mv genesis.cosmoshub-4.json $HOME/config/genesis.json

    # Configure seeds and peers
    wget -nv -O $HOME/config/addrbook.json https://dl2.quicksync.io/json/addrbook.cosmos.json
    sed -i 's|^seeds =.*|seeds = "bf8328b66dceb4987e5cd94430af66045e59899f@public-seed.cosmos.vitwit.com:26656,ba3bacc714817218562f743178228f23678b2873@public-seed-node.cosmoshub.certus.one:26656"|g' $HOME/config/config.toml

    # Configure gas price
    sed -i 's|^minimum-gas-prices =.*|minimum-gas-prices = "0.0025uatom"|g' $HOME/config/app.toml

    # Configure pruning of state
    ## see: https://github.com/cosmos/gaia/blob/main/docs/docs/hub-tutorials/join-mainnet.md#pruning-of-state
    sed -i 's|^pruning =.*|pruning = "default"|g' $HOME/config/app.toml

    # Enable prometheus
    ## see: https://docs.polygon.technology/pos/how-to/full-node/full-node-binaries/#configure-heimdall-seeds-mainnet
    sed -i 's|^prometheus =.*|prometheus = "true"|g' $HOME/config/config.toml
    sed -i 's|^max_open_connections =.*|max_open_connections = 100|g' $HOME/config/config.toml

    # Download pruned snapshot
    # Or check in https://polkachu.com/tendermint_snapshots/cosmos for 15Gi snapshot
    wget -O cosmoshub-4-pruned.tar.lz4 https://dl2.quicksync.io/cosmoshub-4-pruned.$(date +'%Y%m%d').0310.tar.lz4 
    lz4 -d cosmoshub-4-pruned.tar.lz4 -o cosmoshub-4-pruned
    tar -xf cosmoshub-4-pruned -C $HOME/config/data/ --strip-components=1
    rm cosmoshub-4-pruned.lz4 cosmoshub-4-pruned
fi

# Start
gaiad start --home $HOME 