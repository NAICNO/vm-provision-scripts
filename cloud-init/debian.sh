# Installation commands for Debian-based distros like Ubuntu, ...

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
