#!/bin/bash

CONFIG_DIR=$HOME

# Important note: Snapshot is not dynamically search so you should pass the version as env variable
# Snapshot can be found here: https://github.com/bnb-chain/bsc-snapshots?tab=readme-ov-file#bendpointmainnet-update-every-three-week
# Example: 
# The current snapshot is : erigon_data_20240520.lz4.000 ... 007
# So the snapshot version is : 20240520
if [ -z "$SNAPSHOT_VERSION" ]; then
  # If SNAPSHOT_VERSION is not set, set it to the default value
  SNAPSHOT_VERSION="20240520"
fi

# NUMBER_FRAGMENT_SNAPSHOT correspond to the number of fragment for 1 snapshot 
if [ -z "$NUMBER_FRAGMENT_SNAPSHOT" ]; then
  # By default, its 7 fragment for 1 complete snapshot
  NUMBER_FRAGMENT_SNAPSHOT="7"
fi


# if chaindata dir not exist, download snapshot
if [ ! -d "$CONFIG_DIR/chaindata" ] || [ -z "$(ls -A $CONFIG_DIR/chaindata)" ]; then
    cd $CONFIG_DIR

    mkdir $CONFIG_DIR/chaindata
    echo -e "\e[32m[+]\e[0m Download snapshot from : https://pub-60a193f9bd504900a520f4f260497d1c.r2.dev/erigon_data_$SNAPSHOT_VERSION.lz4.*"
    for torrent in $(seq -f "https://pub-60a193f9bd504900a520f4f260497d1c.r2.dev/erigon_data_$SNAPSHOT_VERSION.lz4.%03g" 0 $NUMBER_FRAGMENT_SNAPSHOT); do
      echo -e "\e[32m[+]\e[0m Download snapshot fragment: $torrent" 
      aria2c -x14 -s14 $torrent
    done
                                      
    echo -e "\e[32m[+]\e[0m Concatenate fragments"
    cat $(seq -f "erigon_data_$SNAPSHOT_VERSION.lz4.%03g" 0 $NUMBER_FRAGMENT_SNAPSHOT) > erigon_data.lz4

    # BSC Archive: 8To
    echo -e "\e[32m[+]\e[0m Extracting snapshot into mdbx.dat"
    lz4 -qd -c erigon_data.lz4 > $CONFIG_DIR/chaindata/mdbx.dat
    echo -e "\e[32m[+]\e[0m Extracting snapshot done."

    rm -rf erigon_data.lz4 erigon_data_$SNAPSHOT_VERSION.lz4*
fi

# Start erigon
echo -e "\e[32m[+]\e[0m Start erigon"
/app/erigon \
    --metrics \
    --metrics.addr=0.0.0.0 \
    --db.size.limit=8TB \
    --datadir=$CONFIG_DIR \
    --chain=bsc \
    --port=30303 \
    --authrpc.port=8551 \
    --torrent.port=42069 \
    --http \
    --http.addr=0.0.0.0 \
    --http.port=8545 \
    --http.vhosts=* \
    --internalcl \
    --http.api=eth,debug,net,trace,web3,erigon