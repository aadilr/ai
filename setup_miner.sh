#!/bin/bash

# Set non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Update system and ensure all packages are up-to-date
apt-get update && apt-get upgrade -y

# Install necessary utilities
apt-get install -y software-properties-common sudo nano tmux jq bc expect

# Add the Deadsnakes PPA for newer Python versions
add-apt-repository -y ppa:deadsnakes/ppa

# Update package lists after adding new repositories
apt-get update

# Ensure python3-venv is installed
apt-get install -y python3.8-venv

# If python3-venv installation fails, reattempt the installation
if ! dpkg -s python3.8-venv >/dev/null 2>&1; then
    echo "Retrying installation of python3.8-venv..."
    apt-get install -y python3.8-venv
fi

# Set up Python environment and install dependencies
python3.8 -m venv venv
source venv/bin/activate
pip install --upgrade pip python-dotenv toml diffusers schedule transformers boto3

# Clone and prepare the miner
git clone https://github.com/heurist-network/miner-release
cd miner-release
pip install -r requirements.txt

# Environment setup and run miner
echo "MINER_ID_0=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" > .env
chmod +x llm-miner-starter.sh
./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq
