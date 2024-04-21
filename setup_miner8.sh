#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# System update and necessary tools installation
apt-get update
apt-get upgrade -y
apt-get install -y sudo tmux jq bc software-properties-common

# Add deadsnakes PPA for Python 3.8
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get install -y python3.8-venv

# Setting up timezone non-interactively
export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# Python and other dependencies
apt-get install -y python3-pip
pip install --upgrade pip
pip install python-dotenv toml diffusers schedule transformers boto3

# Clone the miner repository
git clone https://github.com/heurist-network/miner-release
cd miner-release

# Install requirements from Python requirements.txt
pip install -r requirements.txt

# Setup environment variables for miner IDs
echo "MINER_ID_0=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" > .env
for i in {1..7}; do
  echo "MINER_ID_$i=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" >> .env
done

# Start tmux sessions to run multiple miner instances
for i in {0..7}; do
  PORT=$((8000 + 2 * i))
  GPU_ID=$i
  tmux new-session -d -s "miner_$i" \
       "./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq --miner-id-index $i --port $PORT --gpu-ids $GPU_ID"
done

echo "All miners started in separate tmux sessions."
