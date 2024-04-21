#!/bin/bash

# Update system and ensure all packages are up-to-date
apt-get update && apt-get upgrade -y

# Install necessary utilities
apt-get install -y software-properties-common sudo nano tmux jq bc expect

# Configure timezone with expect before any potential prompts during other installations
expect <<EOF
spawn sudo dpkg-reconfigure tzdata
expect "Geographic area:"
send -- "2\r"
expect "Time zone:"
send -- "87\r"
expect eof
EOF

# Add the Deadsnakes PPA for newer Python versions
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update

# Install Python environment
apt-get install -y python3.8-venv

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
