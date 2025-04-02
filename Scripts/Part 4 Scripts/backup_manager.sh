#!/bin/bash

                                                                #  folder where backups will be stored
limit=30                                                                          # Number of most recent backups to be kept
                                           # Log file to keep track of backup operations

source .env

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo " .env file not found!"
    exit 1
fi

touch "$LOG_FILE2"                                                                 # Create log file if not exists

# Ensure the script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root" >&2
    exit 1
fi

# Check if backup Backupp exists, if not, create it
if [ ! -d "$Backupp" ]; then
    echo "Backup Backupp does not exist. Creating..... $Backupp" | tee -a "$LOG_FILE2"
    mkdir -p "$Backupp"
fi


# FUNCTIONS

# Function to add log messages with timestamp (i)
log1() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE2"
}

# Function to create a backup (ii)
create_backup2() {
    local FILE_NAME="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"                    # Generate the backup filename
    local backup_path="$Backupp/$FILE_NAME"                                     # Backup file full path

    
    log1 "Starting backup: $FILE_NAME"
    if tar -czf "$backup_path" "${BACKUP_DIRS[@]}" 2>>"$LOG_FILE2"; then
        log1 "Backup created successfully: $backup_path"
        verify_backup "$backup_path"                                            # call the Verify_Backup function with arguement
    else
        log1 "Error: Backup creation failed"
        rm -f "$backup_path"
        exit 1
    fi
}

# Function to verify backup integrity if it was created properly
verify_backup() {
    log1 "Verifying backup: $1"      
    if tar -tzf "$1" &>/dev/null; then            # check file
        log1 "Backup verified successfully: $1"
    else
        log1 "Error: Backup verification failed - $1 may be corrupt"
        exit 1
    fi
}

# Function to delete old backups exceeding the limit
rotate_backups3() {
    log1 "| Starting backup rotation (keeping last $limit backups)"
    local backups=($(ls -t "$Backupp"/backup_*.tar.gz 2>/dev/null))

    if [ "${#backups[@]}" -le "$limit" ]; then                                            # check if the backup files are enough
        log1 "| No old backups to remove"
        return
    fi
    for ((i=limit; i<${#backups[@]}; i++)); do                                           # check if the file greater than the limit
        log1 "| Removing old backup: ${backups[i]}"
        rm -f "${backups[i]}"
    done
    log1 "| Backup rotation completed"
}

# Main execution process 

log1 "--- Backup process started .........."                                                     # call functions
create_backup2                                                                                  # Create a new backup
rotate_backups3                                                                                   # Rotate backups if needed
log1 "| Backup process completed!"

# List existing backups for reference
log1 "| Current backups in $Backupp:"
ls -lh "$Backupp"/backup_*.tar.gz 2>/dev/null | tee -a "$LOG_FILE2"

exit 0