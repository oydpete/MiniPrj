#!/bin/bash
set -euo pipefail

source .env

# Configuration
USERNAME="adminuser"
SSH_DIR="/home/$USERNAME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Create user if not exists
if ! id "$USERNAME" &>/dev/null; then
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$USERNAME"
fi

# Setup SSH directory
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"
sudo chown "$USERNAME:$USERNAME" "$SSH_DIR"

# Generate SSH key if not exists
if [ ! -f "$SSH_DIR/id_ed25519" ]; then
    sudo -u "$USERNAME" ssh-keygen -t ed25519 -f "$SSH_DIR/id_ed25519" -N ""
fi

# Configure authorized_keys
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    sudo -u "$USERNAME" cp "$SSH_DIR/id_ed25519.pub" "$AUTHORIZED_KEYS"
    sudo chmod 600 "$AUTHORIZED_KEYS"
fi

# Create SSH config
sudo -u "$USERNAME" tee "$SSH_DIR/config" >/dev/null <<EOF
Host target-server
    Hostname $target_ip
    User $USERNAME
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
Host admin-server
    Hostname $admin_ip
    User $USERNAME
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
EOF

# Copy public key to clipboard (for manual distribution if needed)
echo "Public key for $USERNAME:"
sudo -u "$USERNAME" cat "$SSH_DIR/id_ed25519.pub"