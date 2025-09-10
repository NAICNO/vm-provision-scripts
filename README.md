# VM Provision Scripts

This repository contains cloud-init scripts and configurations that are executed during virtual machine provisioning. These scripts automate the setup of software environments, particularly for scientific computing workflows using EESSI (European Environment for Scientific Software Installations) and CernVM-FS.

## Overview

The VM provision scripts provide automated installation and configuration of:

- **CernVM-FS**: A network file system for software distribution
- **EESSI**: A ready-to-use software stack for scientific computing
- **Project-specific environments**: Custom configurations for different research projects

## Repository Structure

```
vm-provision-scripts/
├── cloud-init/                    # Main cloud-init scripts directory
│   ├── debian.sh                  # Provisioning script for Debian-based distributions
│   ├── rhel.sh                    # Provisioning script for RHEL-based distributions
│   └── projects/                  # Project-specific configurations
│       ├── README.md              # Guide for adding project configurations
│       └── jupyter-notebook/      # Jupyter Notebook setup example
│           ├── README.md          # Detailed documentation
│           └── jupyter_init.sh    # Jupyter Notebook initialization script
├── LICENSE                        # GNU General Public License v2
└── README.md                      # This file
```

## Supported Distributions

### Debian-based Distributions
- Ubuntu
- Debian
- Other APT-based systems

**Script**: `cloud-init/debian.sh`

### RHEL-based Distributions
- CentOS
- Rocky Linux
- AlmaLinux
- Fedora
- Other YUM/DNF-based systems

**Script**: `cloud-init/rhel.sh`

## Core Components

### CernVM-FS
The scripts install and configure CernVM-FS, a network file system designed to deliver software to computing nodes. Configuration includes:
- Single client profile (no squid proxy)
- 10GB local cache quota
- EESSI repository access

### EESSI Integration
[EESSI](https://www.eessi.io) provides a ready-to-use software stack for scientific computing. The scripts:
- Install EESSI configuration for CernVM-FS
- Wait for EESSI repository availability (30-second timeout)
- Source the EESSI initialization script (version 2023.06)

## Usage

### Basic Cloud-Init Setup

For **Debian-based systems**:
```bash
bash cloud-init/debian.sh
```

For **RHEL-based systems**:
```bash
bash cloud-init/rhel.sh
```

### Project-Specific Configurations

The `cloud-init/projects/` directory contains specialized configurations for specific research projects or software environments.

#### Jupyter Notebook Example
```bash
# Navigate to the project directory
cd cloud-init/projects/jupyter-notebook/

# Run the Jupyter initialization script
./jupyter_init.sh <token> [start_url] [complete_url]
```

**Parameters:**
- `token`: Authentication token for Jupyter Notebook (required)
- `start_url`: HTTP callback URL for initialization start (optional)
- `complete_url`: HTTP callback URL for initialization completion (optional)

## Project-Specific Configurations

### Adding New Projects

To add a new project configuration:

1. Create a new directory under `cloud-init/projects/`
2. Include a `README.md` with:
   - Project name and description
   - Installation requirements
   - Usage instructions
   - Configuration details
3. Add your initialization scripts
4. Follow the existing patterns for error handling and logging

### Jupyter Notebook Project

The Jupyter Notebook project provides:
- Automatic Jupyter server startup on port 8008
- Token-based authentication
- External access configuration (IP binding to 0.0.0.0)
- HTTP callback mechanism for status reporting
- Comprehensive error handling
- Connection information file generation
- Environment modules integration

See `cloud-init/projects/jupyter-notebook/README.md` for detailed documentation.

## Error Handling

The scripts include robust error handling:
- **Missing dependencies**: Scripts verify required tools are available
- **Network issues**: Timeout mechanisms for repository access
- **Port conflicts**: Validation for service ports
- **Process validation**: Confirmation of successful service startup
- **HTTP callbacks**: Status reporting for remote monitoring

## Requirements

### System Requirements
- Supported Linux distribution (Debian or RHEL-based)
- Internet connectivity for package downloads
- Sufficient disk space for software cache (minimum 10GB recommended)

### Required Tools
- `curl` - For HTTP operations and downloads
- `wget` - For package downloads (Debian systems)
- `ss` - For network port checking
- `ip` - For network interface detection

### Optional Dependencies
- Environment Modules system (for project-specific configurations)
- Project-specific software (e.g., Jupyter Notebook)

## Security Considerations

- Scripts run with elevated privileges for system package installation
- Network services (like Jupyter) are configured with authentication tokens
- External access is enabled for development/research environments
- Review and customize security settings for production deployments

## Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Add your project configuration** following existing patterns
4. **Include comprehensive documentation**
5. **Test your scripts** on target distributions
6. **Submit a pull request**

### Guidelines
- Follow existing code style and error handling patterns
- Include detailed README files for new projects
- Test scripts on both Debian and RHEL-based systems where applicable
- Ensure proper error reporting and logging

## License

This project is licensed under the GNU General Public License v2 - see the [LICENSE](LICENSE) file for details.

## Links

- [EESSI Documentation](https://www.eessi.io)
- [CernVM-FS Documentation](https://cvmfs.readthedocs.io)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io)
