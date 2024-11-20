# Installation commands for Debian-based distros like Ubuntu, ...
# Ask: add environment variable to load huggingface username and token as HF_USERNAME and HF_TOKEN
# Ask: Add another environment variable for authentication for vLLM calling it VLLM_GAIJ_KEY
# Ask: Please open port 8000 for the vLLM to work
# Name: GAIJ
# Contributors: Nuno Calaim, Oihane Horno, Nuno Loureiro, Leonardo Rydin

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
