#!/bin/bash

# Define the path to the .env file
ENV_FILE="/mnt/c/Users/P.I/Documents/Github2/March/MiniPrj/.env"

# Check if the .env file exists
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE..."
    source "$ENV_FILE"
else
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Set up Static IP Address (Example for VM1)
echo "Configuring static IP for VM1..."
cat <<EOF > /etc/netplan/00-static.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${VM1_IP}/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
netplan apply
echo "Static IP configured for VM1: ${VM1_IP}"

# Setup SSH Key-based Authentication
echo "Configuring SSH key-based authentication..."
mkdir -p /home/$SSH_USER/.ssh
chmod 700 /home/$SSH_USER/.ssh
touch /home/$SSH_USER/.ssh/authorized_keys
chmod 600 /home/$SSH_USER/.ssh/authorized_keys
chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh
echo "SSH key-based authentication configured."

# Secure SSH Configuration
echo "Disabling root login and password authentication in SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
echo "SSH secured."

# Configure UFW Firewall
echo "Setting up firewall rules..."
ufw allow OpenSSH
ufw allow from ${VM2_IP} to any port 22
ufw allow from ${VM3_IP} to any port 22
ufw enable
echo "Firewall rules applied."

# Save Firewall Rules Log
echo "Saving firewall rules log..."
ufw status > /var/log/firewall.log
echo "Firewall rules saved to /var/log/firewall.log"

# Set Up Private Network
echo "Configuring private network..."
ip route add 192.168.2.0/24 via ${VM2_IP}
ip route add 192.168.3.0/24 via ${VM3_IP}
echo "Private network configured."

# Test DNS Resolution
echo "Testing DNS resolution..."
nslookup google.com > /var/log/dns_test.log
echo "DNS resolution test log saved in /var/log/dns_test.log"

echo "Network setup completed successfully!"
