#!/bin/bash

VM=$(hostname)
VM_IP=$(hostname -I | grep -oP '192\.168\.\d+\.\d+')
VM2_IP="192.168.56.14"
VM1_IP="192.168.56.13"
SSH_USER="Admin"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

#######################################################

# Set up Static IP Address 
cat <<EOF > /etc/netplan/00-static.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - $VM_IP/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
netplan apply
echo "Static IP configured for $VM: $VM_IP"

######################################################################

# Ensure SSH user exists before proceeding
if ! id "$SSH_USER" &>/dev/null; then
    echo "User $SSH_USER does not exist. Creating user..."
    sudo useradd -m -s /bin/bash "$SSH_USER"
    echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$SSH_USER
fi

# Setup SSH Key-based Authentication
# echo "Configuring SSH key-based authentication..."
mkdir -p /home/$SSH_USER/.ssh
chmod 700 /home/$SSH_USER/.ssh
touch /home/$SSH_USER/.ssh/authorized_keys
chmod 600 /home/$SSH_USER/.ssh/authorized_keys
chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh
echo "SSH key-based authentication configured."

# Secure SSH Configuration
# echo "Disabling root login and password authentication in SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh
echo "SSH secured."

##############################################################

# Step 3: Implement basic firewall rules using iptables or ufw
# echo "Setting up firewall rules using ufw..."
if ! command -v ufw &>/dev/null; then
    echo "UFW is not installed. Installing now..."
    sudo apt update && sudo apt install -y ufw
else 
	echo "UFW Ready For Setting Rules" 
fi

ufw allow OpenSSH

# Only run this line in Admin Server
if [ "$VM" = "Admin" ]; then
    ufw allow from $VM2_IP to any port 22
elif [ "$VM" = "Target" ]; then
    ufw allow from $VM1_IP to any port 22
fi

echo "y" | sudo systemctl restart ssh

ufw enable

echo "y" | sudo systemctl restart ssh

echo "Firewall rules applied."

# Save Firewall Rules Log
#echo "Saving firewall rules log..."
ufw status verbose > /var/log/firewall.log
echo "Firewall rules saved to /var/log/firewall.log"

#######################################################################

# Part 4: Set up a private network between your servers
echo "Configuring private network..."
if [ "$VM" = "Admin" ]; then
    ip route add 192.168.2.0/24 via $VM2_IP
elif [ "$VM" = "Target" ]; then
    ip route add 192.168.2.0/24 via $VM1_IP
fi
echo "Private Network Between Admin and Target VM created Successfully"

###############################################################

# Part 5: Configure and test DNS resolution
#echo "Testing DNS resolution..."
dig google.com > /var/log/dns_test.log
echo "DNS resolution test log saved in /var/log/dns_test.log"

echo "Network setup completed successfully!"

