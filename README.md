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

## Links

- [EESSI Documentation](https://www.eessi.io)
- [CernVM-FS Documentation](https://cvmfs.readthedocs.io)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io)
