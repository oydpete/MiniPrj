#!/bin/bash

# Define the output file for storing system information
OUT="system_report.txt"

# Function to print a divider line
divider() {
    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ " >> "$OUT"
}


# Centralization Function
center_text() {
    text="$1"
    width=80 
    padding=$(( (width - ${#text}) / 2 )) 
    printf "%*s%s%*s\n" $((padding)) "" "$text" $((padding)) >> "$OUT"

}


# Function for collecting hardware information
hardware_info() {
    echo "" >> "$OUT"
    center_text "HARDWARE INFORMATION" >> "$OUT"    # Heading 1
    echo "" >> "$OUT"
    
    echo "CPU Info:" >> "$OUT"  # Label for CPU information
    lscpu >> "$OUT"  # Get CPU details and append to output file
    echo "" >> "$OUT"  # Add a blank line for readability

    echo "Memory Info:" >> "$OUT"  # Label for memory information
    free -h >> "$OUT"  # Get memory usage in human-readable format and append to output file
    echo "" >> "$OUT"  # Add a blank line for readability

    echo -e "The Disk Usage:\n" >> "$OUT"  # Label for disk usage
    df -h >> "$OUT"  # Get disk space usage in human-readable format and append to output file
    echo -e "\n" >> "$OUT"  # Add a blank line for readability
}

# Function to list installed packages
installed_packages() {
     echo "" >> "$OUT"
    center_text "INSTALLED PACKAGE" >> "$OUT"    # Heading 1
    echo "" >> "$OUT"
    if command -v dpkg &> /dev/null; then  # Check if dpkg (Debian-based package manager) is available
        dpkg --list >> "$OUT"  # List installed packages using dpkg and append to output file
    else
        echo "Package manager not found!" >> "$OUT"  # Print an error if no package manager is found
    fi
    echo "" >> "$OUT"  # Add a blank line for readability
}

# Function to identify running services
running_services() {
     echo "" >> "$OUT"
    center_text "RUNNING SERVICES" >> "$OUT"    # Heading 1
    echo "" >> "$OUT" # Add section header to output file

    systemctl list-units --type=service --state=running >> "$OUT"  # List running services and append to output file
    echo "" >> "$OUT"  # Add a blank line for readability
}

# Main execution: Call functions to gather system information
echo "Hostname: $(hostname)" | tee -a "$OUT"
divider
hardware_info  # Collect CPU, memory, and disk usage info
divider
installed_packages  # Collect list of installed packages
divider
running_services  # Collect list of running services
divider

echo "System report generated in $OUT"  # Print message to indicate completion
