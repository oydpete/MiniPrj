#!/bin/bash

# Load environment variables from .env file
ENV_FILE="/mnt/c/Users/P.I/Documents/Github2/March/MiniPrj/.env"

if [ -f "$ENV_FILE" ]; then
    set -a  # Export variables
    source "$ENV_FILE"
    set +a  # Stop exporting
else
    echo ".env file not found! Exiting."
    exit 1
fi

# Define log files
LOG_FILE="/var/log/system_maintenance.log"
EMAIL_LOG_FILE="/var/log/email_notifications.log"

# Ensure log directories exist
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE" "$EMAIL_LOG_FILE"

# Function to log messages with timestamp
log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$LEVEL] $MESSAGE" | tee -a "$LOG_FILE"
}

# Function to send critical alerts via email
send_email_alert() {
    local SUBJECT="$1"
    local BODY="$2"
    if [ -n "$ADMIN_EMAIL" ]; then
        echo -e "Subject:$SUBJECT\n\n$BODY" | sendmail "$ADMIN_EMAIL"
        echo "$(date '+%Y-%m-%d %H:%M:%S') [EMAIL] Sent alert: $SUBJECT" >> "$EMAIL_LOG_FILE"
    else
        log_message "ERROR" "ADMIN_EMAIL not set in .env file. Email alert not sent."
    fi
}

# Create cron jobs
log_message "INFO" "Setting up cron jobs..."

TEMP_CRON=$(mktemp)
crontab -l 2>/dev/null > "$TEMP_CRON"

echo "0 0 * * 0 /usr/bin/env bash /path/to/system_inventory.sh >> $LOG_FILE 2>&1" >> "$TEMP_CRON"   # Weekly inventory
echo "0 * * * * /usr/bin/env bash /path/to/network_monitor.sh >> $LOG_FILE 2>&1" >> "$TEMP_CRON"   # Hourly network monitoring
echo "30 2 * * * /usr/bin/env bash /path/to/backup.sh >> $LOG_FILE 2>&1" >> "$TEMP_CRON"           # Daily backups at 2:30 AM
echo "0 3 * * * /usr/bin/env bash /path/to/system_updates.sh >> $LOG_FILE 2>&1" >> "$TEMP_CRON"   # Daily updates at 3 AM

crontab "$TEMP_CRON"
rm "$TEMP_CRON"

log_message "INFO" "Cron jobs configured."

# Setup log rotation (requires sudo)
if [ "$(id -u)" -ne 0 ]; then
    log_message "ERROR" "Script must be run as root to configure log rotation."
    exit 1
fi

cat <<EOF > /etc/logrotate.d/system_maintenance
$LOG_FILE {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
$EMAIL_LOG_FILE {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
EOF

log_message "INFO" "Log rotation configured."

# Test email notifications for critical errors
send_email_alert "Test Alert: System Maintenance Setup" "Cron jobs and logging setup completed successfully."
log_message "INFO" "Test email sent to $ADMIN_EMAIL."

log_message "INFO" "System maintenance setup complete."
