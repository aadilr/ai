from flask import Flask, render_template, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/start-miners', methods=['POST'])
def start_miners():
    data = request.json
    num_gpus = data['num_gpus']
    miner_address = data['miner_address']
    setup_miners(num_gpus, miner_address)
    return jsonify({'message': 'Miners are starting...'})

def setup_miners(num_gpus, miner_address):
    # Clear existing .env file
    with open('/workspace/miner-release/.env', 'w') as f:
        for i in range(int(num_gpus)):
            f.write(f"MINER_ID_{i}={miner_address}\n")
    
    # Start miners in tmux sessions
    for i in range(int(num_gpus)):
        port = 8000 + 2 * i
        log_file = f"/workspace/logs/miner_{i}.log"
        cmd = f"tmux new-session -d -s 'miner_{i}' './llm-miner-starter.sh openhermes-mixtral-8x7b-gptq --miner-id-index {i} --port {port} --gpu-ids {i} 2>&1 | tee {log_file}'"
        subprocess.run(cmd, shell=True, check=True)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
