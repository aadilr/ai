#!/bin/bash

# Set non-interactive to avoid any interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Clone the miner repository
git clone https://github.com/heurist-network/miner-release /app/miner-release
cd /app/miner-release

# Set up the Python environment
python3.8 -m venv venv
source venv/bin/activate

# Upgrade pip and install required Python packages
pip install --upgrade pip
pip install -r requirements.txt
pip install python-dotenv toml diffusers schedule transformers boto3

# Configure environment variables for the miner
echo "MINER_ID_0=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" > .env

# Give execution permissions and run the miner start script
chmod +x llm-miner-starter.sh
./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq
