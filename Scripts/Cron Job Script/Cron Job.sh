#!/bin/bash

# Load environment variables from .env file
ENV_FILE="/vagrant/.env"

SysInv="/vagrant/Scripts/Part4/system_inventory.sh"
Monitor="/vagrant/Scripts/Part6/Monitoring.sh"
Backupp="/vagrant/Scripts/Part4/backup_manager.sh"
Upt="/vagrant/Scripts/CronJob/Checking_updates.sh"

if [ -f "$ENV_FILE" ]; then
    set -a  # Export variables
    source "$ENV_FILE"
    set +a  # Stop exporting
else
    echo ".env file not found! Exiting."
    exit 1
fi

# Define log file paths
LOG_FILE="/var/log/system_maintenance.log"
EMAIL_LOG_FILE="/var/log/Sent_notifications.log"

# Create log files if they do not exist
touch "$LOG_FILE" "$EMAIL_LOG_FILE"

# Function to log messages with timestamp
log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') || $LEVEL: $MESSAGE" | tee -a "$LOG_FILE"
}

# Function to send critical alerts via email
send_email_alert() {
    local SUBJECT="$1"
    local BODY="$2"
    if ! command -v sendmail &> /dev/null; then
        log_message "ERROR" "sendmail is not installed. Please install it using: sudo apt install -y postfix mailutils"
        return 1
    fi
    if [ -n "$ADMIN_EMAIL" ]; then
        echo -e "Subject:$SUBJECT\n\n$BODY" | sendmail "$ADMIN_EMAIL"
        echo "EMAIL Alert: $SUBJECT Sent at $(date '+%Y-%m-%d %H:%M:%S')" >> "$EMAIL_LOG_FILE"
    else
        log_message "ERROR" "ADMIN_EMAIL not found."
    fi
}

# Validate script paths before setting up cron jobs
for script in "$SysInv" "$Monitor" "$Backupp" "$Upt"; do
    if [ ! -f "$script" ]; then
        log_message "ERROR" "Script not found: $script"
        exit 1
    fi
done

# Set up cron jobs
log_message "INFO" "Setting up cron jobs..."
CRONN=$(mktemp)
crontab -l 2>/dev/null || true > "$CRONN"

echo "0 0 * * 0 /usr/bin/env bash $SysInv >> $LOG_FILE 2>&1" >> "$CRONN"
echo "0 * * * * /usr/bin/env bash $Monitor >> $LOG_FILE 2>&1" >> "$CRONN"
echo "5 1 * * * /usr/bin/env bash $Backupp >> $LOG_FILE 2>&1" >> "$CRONN"
echo "0 2 * * * /usr/bin/env bash $Upt >> $LOG_FILE 2>&1" >> "$CRONN"

crontab "$CRONN"
rm "$CRONN"
log_message "INFO" "Cron Jobs Are Ready."

# Setup log rotation (requires sudo)
if [ "$(id -u)" -ne 0 ]; then
    log_message "ERROR" "Script must be run as root to configure log rotation."
    exit 1
fi

cat <<EOF > /etc/logrotate.d/system_maintenance
/var/log/system_maintenance.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
/var/log/Sent_notifications.log {
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
