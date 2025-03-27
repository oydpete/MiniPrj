#!/bin/bash


## Center Text Function (Formats Output Nicely)
center_text() {
    text="$1"
    width=80 
    padding=$(( (width - ${#text}) / 2 )) 
    printf "%*s%s%*s\n" $((padding)) "" "$text" $((padding))
}


# Function to create a new user
create_user() {
    read -p "New username: " username  # Enter Username
    if id "$username" &>/dev/null; then  # Check if the user already exists
        echo "The User $username already exists"
        return 1
    fi

    useradd -m "$username"  # Create user with home directory

    # Check if `pwscore` is installed before using it, and install if missing
    if ! command -v pwscore &>/dev/null; then
        echo "pwscore is not installed. Installing now..."
        apt update && apt install -y libpwquality-tools
    fi

    while true; do
        read -s -p "Enter password for $username: " password
        echo ""
        read -s -p "Confirm password: " password_confirm
        echo ""

        # Check if passwords match
        if [[ "$password" != "$password_confirm" ]]; then
            echo "Error: Passwords do not match. Please try again."
            continue
        fi

        # Check password strength using `pwscore`
        score=$(echo "$password" | pwscore)
        if [[ "$score" -lt 50 ]]; then
            echo "Error: Password is too weak. Please try again."
            continue
        fi

        # Attempt to set the password
        echo "$username:$password" | chpasswd 2>/tmp/password_error.log
        if [[ $? -ne 0 ]]; then
            error_message=$(cat /tmp/password_error.log)
            echo "Error: Failed to set password because it doesn't meet policy requirements."
            echo "Details: $error_message"
            rm -f /tmp/password_error.log
            continue
        fi

        break  # Exit loop if password is successfully set
    done

    echo "The user $username was created successfully."

    # Option to set up SSH key for secure remote access
    read -p "Do you want to set up SSH access for $username? (y/n): " ssh_choice
    if [[ "$ssh_choice" == "y" ]]; then
        user_home=$(eval echo ~$username)  # Get home directory dynamically
        mkdir -p "$user_home/.ssh"  # Create SSH directory
        touch "$user_home/.ssh/authorized_keys"  # Create authorized keys file
        chmod 700 "$user_home/.ssh"  # Secure directory permissions
        chmod 600 "$user_home/.ssh/authorized_keys"  # Secure file permissions
        chown -R "$username:$username" "$user_home/.ssh"  # Ensure proper ownership
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
        echo "Password Policy already enforced."
    else
        # Add password complexity rule to PAM
        echo "password requisite pam_pwquality.so retry=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
        echo "Password Policy enforced."
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


# For Choices

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
