# Jupyter Notebook Initialization Script

## Overview

The `jupyter_init.sh` script is a VM provisioning script that automatically sets up and starts a Jupyter Notebook server on a virtual machine. This script is designed to be executed during VM initialization as part of the cloud-init process.

## Features

- Automatically starts Jupyter Notebook server on port 8008
- Configures external access with IP binding to 0.0.0.0
- Implements token-based authentication
- Provides HTTP callback mechanism for status reporting
- Includes comprehensive error handling and validation
- Generates connection information file for users
- Uses environment modules for dependency management

## Prerequisites

- **Environment Modules**: The script expects the module system to be available
- **JupyterNotebook Module**: Must be available through `module load JupyterNotebook`
- **Network Tools**: Requires `ss` command for port checking
- **curl**: Required for HTTP status callbacks
- **ip**: Required for VM IP address detection

## Usage

```bash
./jupyter_init.sh <TOKEN> <JUPYTER_INIT_START_URL> <JUPYTER_INIT_COMPLETE_URL>
```

### Parameters

1. **TOKEN** (required): Authentication token for the Jupyter Notebook server
2. **JUPYTER_INIT_START_URL** (optional): HTTP endpoint to notify when initialization starts
3. **JUPYTER_INIT_COMPLETE_URL** (optional): HTTP endpoint to notify when initialization completes

### Example

```bash
./jupyter_init.sh "my-secure-token-123" "https://api.example.com/jupyter/start" "https://api.example.com/jupyter/complete"
```

## Output Files

The script creates files in the `$HOME/.jupyter` directory:

### `jupyter_info.txt`
Contains connection information including:
- VM IP address
- Port number (8008)
- Authentication token
- Full connection URL
- Process ID (PID)
- Timestamp
- Instructions for connecting and stopping the server

### `jupyter.log`
Contains the Jupyter Notebook server logs for troubleshooting.

## Server Configuration

- **Port**: 8008 (hardcoded)
- **IP Binding**: 0.0.0.0 (allows external connections)
- **Browser**: Disabled (--no-browser flag)
- **Authentication**: Token-based

## Status Callbacks

The script supports HTTP callbacks to track initialization progress:

### Start Callback
- **URL**: JUPYTER_INIT_START_URL parameter
- **Method**: POST
- **Data**: `status=init_started`

### Completion Callback
- **URL**: JUPYTER_INIT_COMPLETE_URL parameter  
- **Method**: POST
- **Data**: `status=init_completed`

### Error Callbacks
- **Data**: `status=failed&reason=<error_reason>`
- **Possible reasons**:
  - `no_token`: Token parameter not provided
  - `port_in_use`: Port 8008 is already occupied
  - `failed_to_start`: Jupyter server failed to start

## Error Handling

The script includes robust error handling for common scenarios:

1. **Missing Token**: Exits with error if token is not provided
2. **Missing Jupyter**: Checks if jupyter-notebook command is available
3. **Port Conflicts**: Verifies port 8008 is available before starting
4. **Startup Validation**: Confirms the server process is running after startup

## Troubleshooting

### Common Issues

**Error: jupyter-notebook not found in PATH**
- Ensure the JupyterNotebook module is properly installed
- Verify the module system is working: `module avail`

**Error: Port 8008 is already in use**
- Check what process is using the port: `ss -ltn "( sport = :8008 )"`
- Kill existing process or choose a different port

**Server fails to start**
- Check the log file at `$HOME/.jupyter/jupyter.log`
- Verify all dependencies are installed
- Ensure sufficient disk space and permissions

### Log Files

- **Server logs**: `$HOME/.jupyter/jupyter.log`
- **Connection info**: `$HOME/.jupyter/jupyter_info.txt`

## Security Considerations

- The server binds to 0.0.0.0, making it accessible from any network interface
- Use strong, unique tokens for authentication
- Consider firewall rules to restrict access to port 8008
- Monitor the log files for suspicious activity

## Integration

This script is designed to be called during VM provisioning and integrates with:
- Cloud-init systems
- VM management platforms that support HTTP callbacks
- Environment module systems (Lmod, Environment Modules)

## Dependencies

- bash shell
- curl (for HTTP callbacks)
- ss (for port checking)
- ip (for network interface detection)
- Environment Modules system
- Jupyter Notebook (via module system)