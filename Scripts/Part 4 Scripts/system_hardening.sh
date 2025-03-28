#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi
Security_Report="/var/log/security_report.log"


logt() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$Security_Report"
}


echo "The Script perform system hardening"

# Configure SSH Securely

apt update && apt upgrade -y
SSHH="/etc/ssh/sshd_config"
echo "Securing SSH..."
sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' "$SSHH"       # Disable root login over SSH
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' "$SSHH"  # Disable password authentication (only allow key-based login)
systemctl restart ssh   # Restart SSH service

logt ": SSH Configured"


# Disabled Unessecary services

echo "Disabling unnecessary services..."
systemctl stop avahi-daemon
systemctl disable avahi-daemon
systemctl stop cups
systemctl disable cups

logt ": Unecessary Services have been Disabled"



# Enable automatic security updates
echo "Enabling automatic security updates..."
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

logt ": Security Update Done"



# Set up firewall (UFW - Uncomplicated Firewall)
echo "Configuring firewall rules..."
if ! command -v ufw &> /dev/null; then
    echo "UFW not found. Installing..."
    apt install -y ufw
    logt "UFW installed."
else
    logt "UFW is already installed."
fi
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH  # Allow SSH access
ufw allow 80/tcp
ufw allow 8080/tcp
ufw enable
Rules="/var/log/firewall_policy.log"  # Create special log
echo "Saving firewall rules to log file..."
echo "Firewall rules as of $(date):" > "$Rules"
ufw status numbered >> "$Rules"
echo "Firewall setup completed. Log saved to $Rules."

    
logt ": Firewall updated"

# Backup original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
logt "Created backup of SSH config at /etc/ssh/sshd_config.bak"
systemctl restart sshd


# Set password policy
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
logt ": Password policies set to Maximum 90 days and Minimum 7 days between changes"

    # Set restrictive umask
 echo "umask 027" >> /etc/profile
logt ": Set restrictive file permissions (umask 027)"



echo "System hardening process completed successfully!"