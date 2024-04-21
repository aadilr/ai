#!/bin/bash

# Update the system
apt-get update
apt-get upgrade -y

# Install necessary packages
apt-get install -y sudo nano tmux jq bc

# Clone the miner repository and navigate into it
git clone https://github.com/heurist-network/miner-release
cd miner-release

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install python-dotenv toml diffusers schedule transformers boto3

# Install Python 3.8 and set up virtual environment (if necessary)
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt install -y python3.8-venv
python3.8 -m venv venv
source venv/bin/activate

# Install PyTorch with CUDA support
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

# Set up the environment variables
echo “MINER_ID_0=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4” > .env

# Run the miner starter script
chmod +x llm-miner-starter.sh
./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq
