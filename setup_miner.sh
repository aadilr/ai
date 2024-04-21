#!/bin/bash

# Update system and install necessary packages
apt-get update && apt-get install -y sudo nano tmux jq bc python3.8-venv expect

# Function to configure timezone with expect
expect <<EOF
spawn sudo add-apt-repository -y ppa:deadsnakes/ppa
expect "Please select the geographic area"
send "2\r"
expect "Please select the city or region"
send "87\r"
expect eof
EOF

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
