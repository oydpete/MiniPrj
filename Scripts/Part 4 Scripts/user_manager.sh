#!/bin/bash

# To Check if you are Root, if not exit
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root" 
   exit 1
fi

# Function to center text in the terminal
center_text() {
    text="$1"
    width=80  # Adjust width as needed
    padding=$(( (width - ${#text}) / 2 ))  # Calculate left padding
    printf "%*s%s\n" $padding "" "$text"
}

# Function to create a new user
create_user() {
    read -p "New username: " username  # Enter Username
    if id "$username" &>/dev/null; then  # Check if the user already exists
        echo "The User $username already exists"
        return 1
    fi
    read -s -p "Enter password for $username: " password
    echo ""
    useradd -m "$username"  # Create a new user with a home directory
    echo "$username:$password" | chpasswd
    echo "The user $username was created successfully."

    # Option to set up SSH key for secure remote access
    read -p "Do you want to set up SSH access for $username? (y/n): " ssh_choice
    if [[ "$ssh_choice" == "y" ]]; then
        mkdir -p /home/$username/.ssh  # Create SSH directory
        touch /home/$username/.ssh/authorized_keys  # Create authorized keys file
        chmod 700 /home/$username/.ssh  # Give user full access to SSH directory
        chmod 600 /home/$username/.ssh/authorized_keys  # Give user full access to key file
        chown -R $username:$username /home/$username/.ssh  # Make the user the owner of the file
        echo "SSH setup for $username completed."
    fi
}

# Function to modify a user
modify_user() {
    read -p "Enter the username to modify: " username
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist!"
        return 1
    fi

    echo "What modification do you want to make?"
    echo "1. Lock the user account"
    echo "2. Change the username"
    read -p "Select an option (1-2): " mod_choice

    case $mod_choice in
        1)
            passwd -l "$username"  # Lock the user account
            echo "User $username has been locked."
            ;;
        2)
            read -p "Enter the new username: " new_username
            if id "$new_username" &>/dev/null; then
                echo "The username $new_username already exists! Choose another."
                return 1
            fi
            usermod -l "$new_username" "$username"  # Change the username
            usermod -d "/home/$new_username" -m "$new_username"  # Rename the home directory
            echo "User $username has been renamed to $new_username."
            ;;
        *)
            echo "Invalid choice! Returning to the main menu."
            ;;
    esac
}

# Function to delete a user
delete_user() {
    read -p "Enter the username to delete: " username
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist!"
        return 1
    fi

    # Ask for confirmation before deleting the user
    read -p "Are you sure you want to delete $username? This action cannot be undone. (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        userdel -r "$username"  # Delete user and remove their home directory
        echo "User $username deleted successfully."
    fi
}

# Function to manage user groups
manage_groups() {
    read -p "Enter the username: " username
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist!"
        return 1
    fi

    read -p "Enter the group name: " groupname
    if ! getent group "$groupname" &>/dev/null; then
        echo "Group $groupname does not exist! Creating it now..."
        groupadd "$groupname"
    fi

    usermod -aG "$groupname" "$username"
    echo "User $username added to group $groupname."
}

# Function to enforce password policies
set_password_policy() {
    echo "Setting password policy..."

    # Enforce minimum password length (10 characters)
    sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 10/' /etc/login.defs

    # Set password expiration (90 days)
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs

    # Check if password complexity is already enforced
    if grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
        echo "Password complexity already enforced."
    else
        # Add password complexity rule to PAM
        echo "password requisite pam_pwquality.so retry=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
        echo "Password complexity enforced."
    fi
}

# Main menu to provide options to the user
while true; do
    echo ""
    center_text "USER MANAGEMENT"    # Heading 1
    echo "" 
    echo "What User Action Are You Doing: "
    echo "1. Create a new user"
    echo "2. Modify an existing user"
    echo "3. Delete a user"
    echo "4. Manage user groups"
    echo "5. Enforce password policies"
    echo "6. Exit"
    read -p "Select Action (1-6): " choice  # Get user input

    case $choice in
        1) create_user ;;  # Call function to create a user
        2) modify_user ;;  # Call function to modify user details
        3) delete_user ;;  # Call function to delete a user
        4) manage_groups ;;  # Call function to manage user groups
        5) set_password_policy ;;  # Call function to enforce password policies
        6) echo "Exiting..."; exit 0 ;;  # Exit the script
        *) echo "Invalid choice! Please select a valid option." ;;  # Handle invalid input
    esac
done
