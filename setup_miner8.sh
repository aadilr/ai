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

# Create a .env file with miner IDs for multiple GPUs
for i in {0..7}; do
  echo "MINER_ID_$i=0xe3B4Edd1Be17cC655b6973277C96321c907AbeE4" >> .env
done

# Ensure the miner starter script is executable
chmod +x llm-miner-starter.sh

# Start mining processes in separate tmux sessions for each GPU, one at a time
for i in {0..7}; do
  PORT=$((8000 + 2 * i))  # calculate unique port number
  GPU_ID=$i              # assign GPU ID
  LOG_FILE="/workspace/logs/miner_$i.log"
  mkdir -p /workspace/logs
  touch "$LOG_FILE"

  echo "Starting miner $i on GPU $GPU_ID at port $PORT..."
  tmux new-session -d -s "miner_$i" "./llm-miner-starter.sh openhermes-mixtral-8x7b-gptq --miner-id-index $i --port $PORT --gpu-ids $GPU_ID 2>&1 | tee $LOG_FILE"

  # Wait for miner to initialize and potentially start mining
  TIMEOUT=600 # 10 minutes timeout
  ELAPSED=0
  CONFIRMED=false
  while [[ $ELAPSED -lt $TIMEOUT ]]; do
    if grep -q '200 OK' "$LOG_FILE"; then
      echo "Miner $i started successfully."
      CONFIRMED=true
      break
    fi
    sleep 30
    ((ELAPSED+=30))
  done

  if [[ "$CONFIRMED" != true ]]; then
    echo "Error starting miner $i, timeout reached."
    tail -n 20 "$LOG_FILE"
    exit 1  # Exit if any miner fails to start correctly
  fi
done

echo "All miners started successfully."
