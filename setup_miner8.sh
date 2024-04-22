#!/bin/bash

# Ensure the script is executed with root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Navigate to the workspace directory (create if it does not exist)
mkdir -p /workspace
cd /workspace

# Update and upgrade the system packages
apt-get update
apt-get upgrade -y

# Install necessary packages
apt-get install -y sudo tmux jq bc python3-pip python3-venv

# Clone the miner software from the GitHub repository
git clone https://github.com/heurist-network/miner-release

# Navigate into the cloned directory
cd miner-release

# Install Python dependencies from requirements file
pip install --upgrade pip
pip install -r requirements.txt

# Install additional Python packages
pip install python-dotenv torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121

# Create a .env file with miner ID
echo "MINER_ID_0=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" > .env

# Ensure the miner starter script is executable
chmod +x llm-miner-starter.sh

# Run the miner starter script in a loop for each GPU
for i in {0..7}; do
  PORT=$((8000 + 2 * i))
  GPU_ID=$i
  LOG_FILE="/workspace/logs/miner_$i.log"
  mkdir -p /workspace/logs
  
  echo "Starting miner $i on GPU $GPU_ID at port $PORT..."
  tmux new-session -d -s "miner_$i" bash -c "\
       ./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq --miner-id-index $i --port $PORT --gpu-ids $GPU_ID 2>&1 | tee $LOG_FILE;\
       while ! grep -q '200 OK' $LOG_FILE; do\
         sleep 10;\
       done;\
       echo 'Miner $i running.'"
       
  sleep 10  # Delay to ensure the miner starts before proceeding
done

echo "All miners started."
