#!/bin/bash

source .env

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo " .env file not found!"
    exit 1
fi


servers=("$admin_ip" "$target_ip" "8.8.8.8" "192.168.56.99")

# Ensure the script runs with root privileges for full monitoring
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script in the root."
    exit 1
fi

# Log location




echo "Logging network activity to: $SAVE"

# Function to check if a command exists and install it if missing
install_if_missing() {
    local cmd="$1"  # Command to check
    local pkg="$2"  # Corresponding package name

    # Check if command exists
    if ! command -v "$cmd" &>/dev/null; then
        echo "$cmd not found. Installing..."
        apt update && apt install -y "$pkg"  # Update package list and install the missing package
    fi
}

# Install required tools if missing
install_if_missing "netstat" "net-tools"  # Install netstat if missing
install_if_missing "ifstat" "ifstat"      # Install ifstat if missing

# Function to monitor active network connections
monitor_connections() {
    echo " Active Network Connections:"

    # Use netstat to list network connections, filter unique IPs, and sort them by occurrence
    netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
}

# Function to detect unusual activity (too many connections from a single IP)
detect_unusual_activity() {
    echo " Checking for suspicious network activity..."

    local threshold=10  # Define threshold for excessive connections

    # Extract IP addresses from netstat, count occurrences, and detect unusual activity
    netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | while read count ip; do
        if [ "$count" -gt "$threshold" ] && [[ "$ip" != "Address" && "$ip" != "" ]]; then
            echo "Potential attack detected: $ip has $count connections!" | tee -a "$SAVE"
        fi
    done
}

# Function to test connectivity to specific servers
# Function to test connectivity to specific servers
test_connectivity() {
    echo " Testing server connectivity..."

    # Define an associative array to map IPs to friendly names
    declare -A server_names
    server_names=(
        ["$admin_ip"]="Admin_Server"
        ["$target_ip"]="target_Server"
        ["$spare_ip"]="Spare_Server"
        ["8.8.8.8"]="Google Server"
        ["192.168.56.99"]="Unknown_Server"
    )

    # Loop through each server and test connectivity using ping
    for server in "${servers[@]}"; do
        if ping -c 3 "$server" &>/dev/null; then
            # Check if the server has a friendly name, otherwise display the IP
            if [[ -n "${server_names[$server]}" ]]; then
                echo " Successfully reached ${server_names[$server]} : $server"
            else
                echo " Successfully reached $server"
            fi
        else
            echo " Could not reach $server" | tee -a "$SAVE"
        fi
    done
}

monitor_bandwidth() {
    echo " Checking bandwidth usage..."

    # Check if ifstat is available, otherwise fallback to sar
    if command -v ifstat &>/dev/null; then
        ifstat -t 1 5  # Show bandwidth usage every second for 5 seconds
    elif command -v sar &>/dev/null; then
        echo "ifstat not found, using 'sar' instead."
        sar -n DEV 1 5 | grep -E "IFACE|eth0"  # Show network stats for eth0 interface
    else
        echo " No bandwidth monitoring tool found (Install ifstat or sysstat for sar)." | tee -a "$SAVE"
    fi
}





# Run all functions and save output to the log file
{
    echo "==============================="
    echo " Network Monitoring Report"
    echo "Generated on: $(date)"  # Print the current date and time
    echo "==============================="
    monitor_connections  # Call function to check active connections
    detect_unusual_activity  # Call function to check for unusual network activity
    test_connectivity  # Call function to test connectivity to servers
    monitor_bandwidth  # Call function to check bandwidth usage
    echo "==============================="
} | tee -a "$SAVE"  # Save output to log file and display on the screen

# Print confirmation message
echo " Monitoring complete. Logs saved at: $SAVE