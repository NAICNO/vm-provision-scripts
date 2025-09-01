#!/bin/bash
set -euo pipefail

module purge
module load JupyterNotebook

PORT=8008
OUTPUT_DIR="$HOME/.jupyter"
mkdir -p "$OUTPUT_DIR"
LOG="$OUTPUT_DIR/jupyter.log"
OUTPUT_FILE="$OUTPUT_DIR/jupyter_info.txt"

# jupyter_token as the first argument
TOKEN=$1

# jupyter_init_start_url as the second argument
JUPYTER_INIT_START_URL=$2

# jupyter_init_complete_url as the third argument
JUPYTER_INIT_COMPLETE_URL=$3

# if token is not provided, call init start url with status=failed and exit
if [ -z "$TOKEN" ]; then
    echo "Error: No token provided" >&2
    if [ -n "$JUPYTER_INIT_START_URL" ]; then
        curl -X POST "$JUPYTER_INIT_START_URL" -d "status=failed&reason=no_token"
    fi
    exit 1
fi


# Check if jupyter-notebook is available
if ! command -v jupyter-notebook >/dev/null 2>&1; then
    echo "Error: jupyter-notebook not found in PATH" >&2
    echo "Please install Jupyter Notebook or check your PATH" >&2
    exit 1
fi

# make a call to jupyter_init_start_url with status=starting
if [ -n "$JUPYTER_INIT_START_URL" ]; then
    curl -fsS -X POST "$JUPYTER_INIT_START_URL" -d "status=init_started&port=$PORT" || true
fi

# Check if the desired port is already in use
if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$PORT )" | grep -q LISTEN; then
    echo "Error: Port $PORT is already in use" >&2
    if [ -n "$JUPYTER_INIT_COMPLETE_URL" ]; then
        curl -fsS -X POST "$JUPYTER_INIT_COMPLETE_URL" -d "status=failed&reason=port_in_use&port=$PORT" || true
    fi
    exit 1
fi

echo "Starting Jupyter Notebook on port $PORT..."

# Start jupyter-notebook with specific port, token, and allow external connections
jupyter-notebook --no-browser --ip=0.0.0.0 --port="$PORT" --NotebookApp.token="$TOKEN" > "$LOG" 2>&1 &

# Get the PID of the jupyter process
JUPYTER_PID=$!

# Wait a moment for the server to start
sleep 3

# Check if the process is still running
if ! kill -0 $JUPYTER_PID 2>/dev/null; then
    echo "Error: Jupyter Notebook failed to start" >&2
    echo "Check $LOG for details" >&2
    if [ -n "$JUPYTER_INIT_COMPLETE_URL" ]; then
        curl -fsS -X POST "$JUPYTER_INIT_COMPLETE_URL" -d "status=failed&reason=failed_to_start&port=$PORT" || true
    fi
    exit 1
fi

# call init_complete_url with status=started with PID and port
if [ -n "$JUPYTER_INIT_COMPLETE_URL" ]; then
    curl -fsS -X POST "$JUPYTER_INIT_COMPLETE_URL" -d "status=completed&pid=$JUPYTER_PID&port=$PORT&url=$JUPYTER_URL&token=$TOKEN" || true
fi

# Construct the full URL with VM IP
VM_IP=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d'/' -f1 | head -1)
JUPYTER_URL="http://${VM_IP}:${PORT}/?token=${TOKEN}"

# Save the information to file
{
    echo "Jupyter Notebook Started Successfully"
    echo "======================================"
    echo "VM IP: $VM_IP"
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
    echo "Log file: $LOG"
} > "$OUTPUT_FILE"
