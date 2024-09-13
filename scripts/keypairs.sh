#!/bin/bash

# Set the chain configuration directory
CHAIN_CONFIG_DIR="${1:-$HOME/chain}"

ENTRYPOINT_COUNT=1

# Number of entrypoint nodes
# Function to generate keypairs
generate_keypair() {
    local name=$1
    local dir=$2
    mkdir -p "$dir"
    if [ ! -f "$dir/$name.json" ]; then
        solana-keygen new --no-passphrase -o "$dir/$name.json"
        echo "Generated $name keypair"
    else
        echo "$name keypair already exists at $dir/$name.json"
    fi
}

# Generate genesis keypairs
echo "Generating genesis keypairs..."
generate_keypair "bootstrap-validator-identity" "$CHAIN_CONFIG_DIR/genesis"
generate_keypair "bootstrap-validator-vote-account" "$CHAIN_CONFIG_DIR/genesis"
generate_keypair "bootstrap-validator-stake-account" "$CHAIN_CONFIG_DIR/genesis"
generate_keypair "faucet" "$CHAIN_CONFIG_DIR"

echo "Keypair generation complete"

# Generate SSH key
echo "Generating SSH key..."
mkdir "$CHAIN_CONFIG_DIR/ssh"
ssh-keygen -t rsa -b 4096 -f "$CHAIN_CONFIG_DIR/ssh/id_rsa" -N ""

echo "Keypair generation complete"