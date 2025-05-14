#!/bin/bash

usage() {
    echo "Usage: $0 <source_directory> <target_directory> [--backup-separate <backup_directory>]"
    exit 1
}

# Must have at least two arguments.
if [ "$#" -lt 2 ]; then
    usage
fi

# Parse required arguments.
SRC_DIR="$1"
TGT_DIR="$2"
shift 2

# Default backup mode: inline backup.
STRUCTURED_BACKUP=false
BACKUP_DIR=""

# Process optional flags.
while [ "$#" -gt 0 ]; do
    case "$1" in
        --backup-separate)
            STRUCTURED_BACKUP=true
            shift
            if [ -z "$1" ]; then
                echo "Error: --backup-separate requires a directory argument"
                exit 1
            fi
            BACKUP_DIR="$1"
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
done

BACKUP_FILE_SUFFIX=".bak.$(date +%Y%m%d)"

# Check if source directory exists.
if [ ! -d "$SRC_DIR" ]; then
    echo "Source directory does not exist: $SRC_DIR"
    exit 1
fi

# Create target directory if it doesn't exist.
mkdir -p "$TGT_DIR"

# If structured backup mode is active, ensure backup folder exists.
if [ "$STRUCTURED_BACKUP" = true ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Create missing directories in target based on the source structure.
find "$SRC_DIR" -type d | while read -r src_dir; do
    # Get the directory relative path.
    rel_dir="${src_dir#$SRC_DIR}"
    tgt_dir="$TGT_DIR/$rel_dir"
    if [ ! -d "$tgt_dir" ]; then
        mkdir -p "$tgt_dir"
        echo "Created directory $tgt_dir"
    fi
done

# Process each file and copy it to the corresponding target location.
find "$SRC_DIR" -type f | while read -r src_file; do
    # Compute the relative path.
    rel_path="${src_file#$SRC_DIR/}"
    tgt_file="$TGT_DIR/$rel_path"
    tgt_dir=$(dirname "$tgt_file")

    # Ensure the target subdirectory exists.
    if [ ! -d "$tgt_dir" ]; then
        mkdir -p "$tgt_dir"
        echo "Created directory $tgt_dir"
    fi

    # If the target file exists, back it up.
    if [ -f "$tgt_file" ]; then
        if [ "$STRUCTURED_BACKUP" = true ]; then
            backup_file="$BACKUP_DIR/$rel_path$BACKUP_FILE_SUFFIX"
            backup_dir=$(dirname "$backup_file")
            mkdir -p "$backup_dir"
            cp "$tgt_file" "$backup_file"
            echo "Backed up $tgt_file to $backup_file"
        else
            backup_file="${tgt_file}${BACKUP_FILE_SUFFIX}"
            cp "$tgt_file" "$backup_file"
            echo "Backed up $tgt_file to $backup_file"
        fi
    fi

    # Copy the source file to the target location.
    cp "$src_file" "$tgt_file"
    echo "Copied $src_file to $tgt_file"
done