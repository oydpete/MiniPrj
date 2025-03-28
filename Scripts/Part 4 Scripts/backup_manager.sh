#!/bin/bash



BACKUP_DIRS=("/home/user/documents" "/etc" "/var/www")          # Directories to back up (Modify these paths as needed)

DESTINATION="/backups"                                          # Destination folder where backups will be stored

limit=3                                                    # Number of most recent backups to be kept

LOG_FILE="/var/log/backup_manager.log"                         # Log file to keep track of backup operations


touch "$LOG_FILE"

#FUNCTIONS

# Function to log messages with timestamp
log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}


if [ "$(id -u)" -ne 0 ]; then                                             # To check if it is in the root
    echo "Please run this script as root " >&2
    exit 1
fi



if [ ! -d "$DESTINATION" ]; then                                      # Check if backup destination exists, if not, create it
    log "Backup destination does not exist. Creating..... $DESTINATION"
    mkdir -p "$DESTINATION"
fi



# Function to create a backup
create_backup() {
    local timestamp=$(date "+%Y%m%d_%H%M%S")                            # Generate the backup timestamp
    local backup_name="backup_$timestamp.tar.gz"                        # Define the backup file name
    local backup_path="$DESTINATION/$backup_name"                       # The Backup Path

    log "Starting backup: $backup_name"

    # Create a compressed archive (tar.gz) of the directories listed in BACKUP_DIRS
    if tar -czf "$backup_path" "${BACKUP_DIRS[@]}" 2>>"$LOG_FILE"; then
        log "Backup created successfully: $backup_path"
        verify_backup "$backup_path"  # Verify the integrity of the created backup
    else
        log "Error: Backup creation failed"
        rm -f "$backup_path"  # Remove the failed backup file
        exit 1
    fi
}

# Function to verify backup integrity
verify_backup() {
    local backup_file="$1"
    log "Verifying backup: $backup_file"

    
    if tar -tzf "$backup_file" &>/dev/null; then                        # Check if the backup file is a valid tar archive
        log "Backup verified successfully: $backup_file"
    else
        log "Error: Backup verification failed - $backup_file may be corrupt"
        exit 1
    fi
}


# Function to delete log after reaching limit
rotate_backups() {
    log " | Starting backup rotation (keeping last $limit backups)"

    # Get a sorted list of existing backups (most recent first)
    local backups=($(ls -t "$DESTINATION"/backup_*.tar.gz 2>/dev/null))
    
    

    if [ "${#backups[@]}" -le "$limit" ]; then            # Check if the number of backups exceeds the retention limit
        log " | No old backups to remove"
        return
    fi
 


    # Delete the oldest backups beyond the retention count
    for ((i=$limit; i<${#backups[@]}; i++)); do
        log " | Removing old backup: ${backups[i]}"
        rm -f "${backups[i]}"
    done

    log " | Backup rotation completed"
}

# Main execution process
log " --- Backup process started .........."
create_backup  # Create a new backup
rotate_backups  # Rotate backups if needed
log " | Backup process completed! "

# List existing backups for reference
log " | Current backups in $DESTINATION:"
ls -lh "$DESTINATION"/backup_*.tar.gz 2>/dev/null | tee -a "$LOG_FILE"

exit 0
