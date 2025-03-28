#!/bin/bash

# Define the output file for storing system information
OUT="system_report.txt"


Divider() {

    echo " +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ " > "$OUT"

}


Divider | tee -a "$OUT"

# Function For Collecting Hardware Information


#
collect_hardware_info() {

    echo "            HARDWARE INFORMATION/n            " > "$OUT"  # Heading 1
    echo "CPU Info:" >> "$OUT"                              # Label for CPU information
    lscpu >> "$OUT"  # Get CPU details and append to output file
    echo "" >> "$OUT"  # Add a blank line for readability
    

    echo "Memory Info:" >> "$OUT"  # Label for memory information
    free -h >> "$OUT"  # Get memory usage in human-readable format and append to output file
    echo "" >> "$OUT"  # Add a blank line for readability
    
    echo "The Disk Usage :/n " >> "$OUT"  # Label for disk usage
    df -h >> "$OUT"  # Get disk space usage in human-readable format and append to output file
    echo "/n" >> "$OUT"  # empty line
}

Divider | tee -a "$OUT"


echo "Hostname: $(hostname)" | tee -a "$REPORT_FILE"

# Function to list installed packages
list_installed_packages() {

    echo "            INSTALLED PACKAGES            " >> "$OUT"  # Heading 2
    if command -v dpkg &> /dev/null; then  # Check if dpkg (Debian-based package manager) is available
        dpkg --list >> "$OUT"  # List installed packages using dpkg and append to output file
    else
        echo "Package manager not found!" >> "$OUT"  # Print an error if no package manager is found
    fi

    echo "" >> "$OUT"  # empty line
}



Divider | tee -a "$OUT"



# Function to identify running services
identify_running_services() {
    echo "            RUNNING SERVICES           " >> "$OUT"  # Add section header to output file

    systemctl list-units --type=service --state=running >> "$OUT"  # List running services and append to output file

    echo "" >> "$OUT"  # Add a blank line for readability
}


Divider | tee -a "$OUT"


# Main execution: Call functions to gather system information
collect_hardware_info  # Collect CPU, memory, and disk usage info
list_installed_packages  # Collect list of installed packages
identify_running_services  # Collect list of running services


Divider | tee -a "$OUT"


echo "System report generated in $OUT"  # Print message to indicate completion
