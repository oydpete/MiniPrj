#!/bin/bash                                                                          

# set -e                                                                                # Exit if an error

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root,Exiting....."
    exit 1
fi

##############################################################################

# Step 1: Create users and configure SSH with Key Authentication
read -p "Enter users to be created , Guildlines:\n 1. For multiple Users space them\n 2. Arrange In order of Priviledge \n: " -a USERS       # Takes in the app input

if ! dpkg -l | grep -q openssh-server; then                                           #  Check if OpenSSH Server is not installed
    echo "OpenSSH server is not installed. Installing now..."
    apt update && apt install -y openssh-server                                       # Install OpenSSH Server
fi

for USER in "${USERS[@]}"; do                                                         # Loop to create multiple users  
    useradd -m "$USER"                                                                # Create user  
    echo -e "Setting up SSH authentication for $USER...\n"                             

    mkdir -p /home/"$USER"/.ssh                                                       # Create .ssh directory  
    chmod 700 /home/"$USER"/.ssh                                                      # Ensure only that user can access `.ssh`  

    sudo -u "$USER" ssh-keygen -t rsa -b 4096 -f /home/"$USER"/.ssh/id_rsa -N ""      # Generate SSH key  

    cat /home/"$USER"/.ssh/id_rsa.pub >> /home/"$USER"/.ssh/authorized_keys           # Append public key  

    chmod 600 /home/"$USER"/.ssh/authorized_keys                                      # Restrict file permissions  
done

echo "Disabling SSH password authentication..."                                       # 

# Use a single sed command to handle both commented and uncommented cases
sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh                                                                 

echo "Assigning permissions..."

# Grant sudo privileges based on roles
for i in "${!USERS[@]}"; do
  if [ $i -eq 0 ]; then
    rule="${USERS[$i]} ALL=(ALL) NOPASSWD:ALL"                                           # First user gets full NOPASSWD access
  else
    rule="${USERS[$i]} ALL=(ALL) ALL"                                                    # Subsequent users get standard sudo access
  fi
  
  echo "$rule" | sudo tee "/etc/sudoers.d/${USERS[$i]}" >/dev/null
  sudo chmod 440 "/etc/sudoers.d/${USERS[$i]}"
done
###################################################

# Step 2: Package Management (Install and configure necessary packages)

echo "Installing necessary packages..."
apt update && apt upgrade -y                                                            # Check for users
apt install -y nginx curl vim                                                           # Install useful tools

##################################################

# Step 3: Disk Setup (If an extra disk is found)

DISK="/dev/sdb"
MOUNT_POINT="/mnt/data"

if lsblk | grep -q "sdb"; then
    echo "Found extra disk: $DISK. Setting it up..."
    printf "n\np\n1\n\n\nw" | fdisk $DISK
    mkfs.ext4 ${DISK}1
    mkdir -p $MOUNT_POINT
    mount ${DISK}1 $MOUNT_POINT
    echo "${DISK}1 $MOUNT_POINT ext4 defaults 0 0" >> /etc/fstab
else
    echo "No extra disk found. Skipping disk setup."
fi

#############################################################

# Step 4: Display setup summary

echo "Setup complete! Here's what we did:"
echo "Users created:"
for USER in "${USERS[@]}"; do
    echo "- $USER (ID: $(id $USER))"
done

echo "Disk usage:"
df -h

echo "Running services:"
ps aux | grep nginx

echo "Setup finished successfully!"
