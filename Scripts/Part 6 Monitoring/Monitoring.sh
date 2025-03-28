#!/bin/bash

# Simple Daily System Report Script
# This script checks system health and saves the report

## Center Text Function (Formats Output Nicely)
center_text() {
    text="$1"
    width=80 
    padding=$(( (width - ${#text}) / 2 )) 
    printf "%*s%s%*s\n" $((padding)) "" "$text" $((padding))
}

# Define Report Folder and File
REPORT_FOLDER="$HOME/system_reports"
mkdir -p "$REPORT_FOLDER"

DAY=$(date +%Y-%m-%d)  # Format: YYYY-MM-DD
REPORT_FILE="$REPORT_FOLDER/$DAY_System_Report.txt"

# Ensure script runs as root for full logs and updates
if [ "$(id -u)" -ne 0 ]; then
    echo "  Warning: Some sections may require root privileges. Run with sudo for full results."
fi

## REPORT GENERATION
{
    echo "" 
    center_text " DAILY SYSTEM REPORT "
    echo "Generated on: $(date)"
    echo ""

    echo "============================================"
    center_text "🔹 SYSTEM UPTIME"
    echo "============================================"
    uptime
    echo ""

    echo "============================================"
    center_text "🔹 DISK SPACE USAGE"
    echo "============================================"
    if command -v df &> /dev/null; then
        df -h | awk '{print $1, $2, $3, $4, $5, $6}'  # Filter useful columns
    else
        echo " 'df' command not found."
    fi
    echo ""

    echo "============================================"
    center_text "🔹 MEMORY USAGE"
    echo "============================================"
    if command -v free &> /dev/null; then
        free -h
    else
        echo " 'free' command not found."
    fi
    echo ""

    echo "============================================"
    center_text "🔹 FAILED LOGIN ATTEMPTS (LAST 10)"
    echo "============================================"
    LOG_FILE="/var/log/auth.log"

    if [ -f "$LOG_FILE" ]; then
        grep "Failed password" "$LOG_FILE" | tail -n 10
    else
        echo "  Could not check login attempts (log file not found)"
    fi
    echo ""

    echo "============================================"
    center_text "🔹 AVAILABLE SYSTEM UPDATES"
    echo "============================================"
    if command -v apt-get &> /dev/null; then
        apt list --upgradable 2>/dev/null || echo " No updates available"
    else
        echo " Could not check updates (unknown package manager)"
    fi
    echo ""

} > "$REPORT_FILE"  # Save output to file

# Display the report path
echo " Report saved to: $REPORT_FILE"
echo " To view the report, type: cat \"$REPORT_FILE\""
