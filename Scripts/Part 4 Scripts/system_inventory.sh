#!/bin/bash

# Define the output file for storing system information
OUT="system_report.txt"

# Function to print a divider
Divider() {
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ " >> "$OUT"
}

# Correct function calls
Divider 

# Function to collect hardware information
collect_hardware_info() {
    # Output cpu info
    echo -e "            HARDWARE INFORMATION\n" >> "$OUT"  # Heading 1
    echo "CPU Info:" >> "$OUT"
    lscpu >> "$OUT"
    echo "" >> "$OUT"
    
    
    # output the memory space
    echo "Memory Info:" >> "$OUT"
    free -h >> "$OUT"
    echo "" >> "$OUT"
    

    # Ouput the Disk usage
    echo -e "The Disk Usage:\n" >> "$OUT"
    df -h >> "$OUT"
    echo "" >> "$OUT"
}

Divider 

# Capture Hostname
echo "Hostname: $(hostname)" | tee -a "$OUT"

# Function to list installed packages
list_installed_packages() {
    echo "            INSTALLED PACKAGES            " >> "$OUT"
    if command -v dpkg &> /dev/null; then
        dpkg --list >> "$OUT"
    else
        echo "Package manager not found!" >> "$OUT"
    fi
    echo "" >> "$OUT"
}

Divider 

# Function to identify running services
identify_running_services() {
    echo "            RUNNING SERVICES           " >> "$OUT"
    systemctl list-units --type=service --state=running >> "$OUT"
    echo "" >> "$OUT"
}

Divider 

# Main execution: Call functions to gather system information
collect_hardware_info
list_installed_packages
identify_running_services

Divider 

echo "System report generated to $OUT"

