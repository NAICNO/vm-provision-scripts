# Installation commands for RHEL-based distros like CentOS, Rocky Linux, Almalinux, Fedora, ...

# install CernVM-FS
sudo yum install -y https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest.noarch.rpm
sudo yum install -y cvmfs

# install EESSI configuration for CernVM-FS
sudo yum install -y https://github.com/EESSI/filesystem-layer/releases/download/latest/cvmfs-config-eessi-latest.noarch.rpm

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
