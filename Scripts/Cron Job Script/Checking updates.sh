#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (use sudo)."
    exit 1
fi

echo "Checking for system updates..."

# Update package lists
sudo apt update
# Show available updates
echo "The following packages can be updated:"
apt list --upgradable
echo "Upgrading packages..."
sudo apt upgrade -y
echo "System upgrade completed
