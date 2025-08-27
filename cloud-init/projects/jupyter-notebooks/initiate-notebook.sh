#!/bin/bash
#sabryr 27-08-2025
#to start jupyternotebook and get the 
#created port and token
#For this to work either
# port forwarding or opning up 8008 is needed
# ssh -N -L 8008:localhost:8008  ubuntu@<IP> -i <keyfile>

module purge
module load JupyterNotebook

# Generate a random port between 8000-9000
#PORT=$((8000 + RANDOM % 1000))
PORT=8008
# Generate a random token
TOKEN=$(openssl rand -hex 12 2>/dev/null || date | md5sum | cut -d' ' -f1 | head -c 16

)
# Check if jupyter-notebook is available
if ! command -v jupyter-notebook >/dev/null 2>&1; then
    echo "Error: jupyter-notebook not found in PATH" >&2
    echo "Please install Jupyter Notebook or check your PATH" >&2
    exit 1
fi


# Output file to save port and token information
OUTPUT_FILE="jupyter_info.txt"

echo "Starting Jupyter Notebook on port $PORT..."

# Start jupyter-notebook with specific port, token, and allow external connections
jupyter-notebook --no-browser --ip=0.0.0.0 --port=$PORT --NotebookApp.token="$TOKEN" > jupyter.log 2>&1 &

# Get the PID of the jupyter process
JUPYTER_PID=$!

# Wait a moment for the server to start
sleep 3

# Check if the process is still running
if ! kill -0 $JUPYTER_PID 2>/dev/null; then
    echo "Error: Jupyter Notebook failed to start" >&2
    echo "Check jupyter.log for details" >&2
    exit 1
fi
# Construct the full URL with VM IP
VM_IP=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d'/' -f1 | head -1)
JUPYTER_URL="${VM_IP}:${PORT}/?token=${TOKEN}"

# Save the information to file
{
    echo "Jupyter Notebook Started Successfully"
    echo "======================================"
    echo "VM IP: 168.37.63.34"
    echo "Port: $PORT"
    echo "Token: $TOKEN"
    echo "URL: $JUPYTER_URL"
    echo "PID: $JUPYTER_PID"
    echo "Timestamp: $(date)"
    echo ""
    echo "To connect from your laptop:"
    echo "1. Open a web browser"
    echo "2. Navigate to: $JUPYTER_URL"
    echo ""
    echo "To stop the server:"
    echo "kill $JUPYTER_PID"
    echo ""
    echo "Log file: jupyter.log"
} > "$OUTPUT_FILE"

echo "Jupyter Notebook started successfully!"
echo "Connection information saved to: $OUTPUT_FILE"
echo ""
echo "External URL: $JUPYTER_URL"
echo "PID: $JUPYTER_PID"
                                      
