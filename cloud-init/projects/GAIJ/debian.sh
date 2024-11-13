# Installation commands for Debian-based distros like Ubuntu, ...
# Ask: add environment variable to load huggingface username and token as HF_USERNAME and HF_TOKEN
# Ask: Add another environment variable for authentication for vLLM calling it VLLM_GAIJ_KEY
# Ask: Please open port 8000 for the vLLM to wor
# Name: GAIJ
# Contributers: Nuno Calaim, Oihane Horno, Nuno Loureiro, Leonardo Rydin

# install CernVM-FS
sudo apt-get install lsb-release
wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
sudo dpkg -i cvmfs-release-latest_all.deb
rm -f cvmfs-release-latest_all.deb
sudo apt-get update
sudo apt-get install -y cvmfs

# install EESSI configuration for CernVM-FS
wget https://github.com/EESSI/filesystem-layer/releases/download/latest/cvmfs-config-eessi_latest_all.deb
sudo dpkg -i cvmfs-config-eessi_latest_all.deb

# create client configuration file for CernVM-FS (no squid proxy, 10GB local CernVM-FS client cache)
sudo bash -c "echo 'CVMFS_CLIENT_PROFILE="single"' > /etc/cvmfs/default.local"
sudo bash -c "echo 'CVMFS_QUOTA_LIMIT=10000' >> /etc/cvmfs/default.local"

# make sure that EESSI CernVM-FS repository is accessible
sudo cvmfs_config setup

# Wait for the file to become available
timeout=30 # Timeout in seconds
elapsed=0

while [ ! -f /cvmfs/software.eessi.io/versions/2023.06/init/bash ]; do
  sleep 1
  ((elapsed++))
  if [ "$elapsed" -ge "$timeout" ]; then
    exit 1
  fi
done

# Source the EESSI init script
source /cvmfs/software.eessi.io/versions/2023.06/init/bash

git clone https://$HF_USERNAME:$HF_TOKEN@huggingface.co/meta-llama/Llama-3.2-3B-Instruct
cd Llama-3.2-3B-Instruct/
git lfs pull
cd ..


python3.12 -m venv .venv-vLLM
source .venv-vLLM/bin/activate
pip install vllm

sudo apt install screen

screen -S vllm

python -m vllm.entrypoints.openai.api_server \
  --model /home/naic-user/Llama-3.2-3B-Instruct \
  --host 0.0.0.0 \
  --port 8000 \
  --max_model_len 65536 \
  --tensor-parallel-size 2 \
  --cpu-offload \
  --gpu-memory-utilization 0.9 \
  --dtype bfloat16 \
  --api-key $VLLM_GAIJ_KEY