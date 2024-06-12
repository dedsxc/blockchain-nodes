#!/bin/bash

CONFIG_DIR=$HOME

# if data dir not exist, init config and download snapshot
if [ ! -d "$CONFIG_DIR/data" ] || [ -z "$(ls -A $CONFIG_DIR/data)" ]; then
    # Init heimdalld
    echo -e "\e[32m[+]\e[0m Init config"
    heimdalld init --chain mainnet --home $CONFIG_DIR

    # Get Genesis.json with sentry
    echo -e "\e[32m[+]\e[0m Download genesis file"
    wget -O $CONFIG_DIR/config/genesis.json https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/sentry/sentry/heimdall/config/genesis.json

    # Configure seeds and peers
    ## see: https://docs.polygon.technology/pos/how-to/full-node/full-node-binaries/#configure-heimdall-seeds-mainnet
    ## see: https://github.com/maticnetwork/node-ansible/blob/master/roles/heimdall/install-heimdall/tasks/main.yml
    echo -e "\e[32m[+]\e[0m Setup seeds and peers"
    sed -i 's|^seeds =.*|seeds = "1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656"|g' $CONFIG_DIR/config/config.toml
    sed -i 's|^persistent_peers =.*|persistent_peers = "1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,82f3085a83faa522c3cafa4e4dce1ef3a0c660f3@13.209.168.182:26656,f2b1ba3a684c4705aff7c01ec1c454a39794db5a@43.201.242.62:26656,bb98b9abd23a9d2e196b2c8a03cfb51a4bd49b47@43.202.78.165:26656,5606200cbdf662620625edea63b6a4275128fb34@3.38.254.221:26656,d76001510004c802fd2977488eb753ef261a245b@15.165.197.16:26656,e56dbf76c7b9508ecece447195382301e7c90ec7@52.78.154.236:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656,ec59b724d669b9df205156e8fd457257116b1745@99.81.158.129:26656,08de3da03bd6774e4c5464dd29ddedddefbb1907@34.254.124.45:26656,78610e49cd8efb28c835c8478b30cf94650335b9@34.252.116.193:26656,e6816ab7fc88522be49940287206391bde87eeb9@54.76.109.39:26656,3215b1cf88ea913f477c0db0be00fb873d826d72@34.246.232.184:26656"|g' $CONFIG_DIR/config/config.toml

    # Enable prometheus
    ## see: https://docs.polygon.technology/pos/how-to/full-node/full-node-binaries/#configure-heimdall-seeds-mainnet
    echo -e "\e[32m[+]\e[0m Enable prometheus monitoring"
    sed -i 's|^prometheus =.*|prometheus = "true"|g' $CONFIG_DIR/config/config.toml
    sed -i 's|^max_open_connections =.*|max_open_connections = 100|g' $CONFIG_DIR/config/config.toml

    # Set name of node
    sed -i 's|^moniker =.*|moniker = "matic-node"|g' $CONFIG_DIR/config/config.toml

    # Download snapshot
    ## See: https://docs.polygon.technology/pos/how-to/snapshots/#downloading-and-using-client-snapshots
    rm -rf $CONFIG_DIR/data
    echo -e "\e[32m[+]\e[0m Downloading snapshot"
    curl -sL https://snapshot-download.polygon.technology/snapdown.sh | sed '/sudo apt-get update -y/d; /sudo apt-get install -y zstd pv aria2/d' | bash -s -- --network mainnet --client heimdall --extract-dir $CONFIG_DIR/data --validate-checksum true > $CONFIG_DIR/snapshot.log
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

# Start heimdalld
echo -e "\e[32m[+]\e[0m Start heimdalld..."
heimdalld start --home $CONFIG_DIR --rest-server --chain mainnet
