#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <backup_directory> <number_of_files_to_keep>"
    echo "Example: $0 /path/to/backups 10"
    exit 1
fi

BACKUP_DIR="$1"
FILES_TO_KEEP="$2"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Directory $BACKUP_DIR does not exist"
    exit 1
fi

# Check if FILES_TO_KEEP is a positive number
if ! [[ "$FILES_TO_KEEP" =~ ^[0-9]+$ ]] || [ "$FILES_TO_KEEP" -lt 1 ]; then
    echo "Error: Number of files to keep must be a positive integer"
    exit 1
fi

find "$BACKUP_DIR" -type f -printf '%T@ %p\n' | sort -n | head -n -"$FILES_TO_KEEP" | cut -d' ' -f2- | xargs echo rm -f