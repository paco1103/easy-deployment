#!/bin/bash

usage() {
    echo "Usage: $0 <source_directory> <target_directory> [--backup-separate <backup_directory>] [--test]"
    exit 1
}

# Helper: run the given command(s) if not in test mode, then echo the message.
run_action() {
    local msg="$1"
    shift
    if [ "$TEST_MODE" = false ]; then
        "$@"
    fi
    echo "$msg"
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
BACKUP_SEPARATE=false
# Default test mode: false.
TEST_MODE=false
# Default backup directory: empty.
BACKUP_DIR=""

# Process optional flags.
while [ "$#" -gt 0 ]; do
    case "$1" in
        --backup-separate)
            BACKUP_SEPARATE=true
            shift
            if [ -z "$1" ]; then
                echo "Error: --backup-separate requires a directory argument"
                exit 1
            fi
            BACKUP_DIR="$1"
            shift
            ;;
        --test)
            TEST_MODE=true
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
if [ ! -d "$TGT_DIR" ]; then
    run_action "Create Directory: $TGT_DIR" mkdir -p "$TGT_DIR"
fi

# If structured backup mode is active, ensure backup folder exists.
if [ "$BACKUP_SEPARATE" = true ]; then
    run_action "Create Directory: $BACKUP_DIR" mkdir -p "$BACKUP_DIR"
fi

echo "Start deploying files: $SRC_DIR -> $TGT_DIR"

# Create missing directories in target based on the source structure.
find "$SRC_DIR" -type d | while IFS= read -r src_dir; do
    rel_dir="${src_dir#$SRC_DIR}"
    tgt_dir="$TGT_DIR/$rel_dir"
    if [ ! -d "$tgt_dir" ]; then
        run_action "Create Directory -> $tgt_dir" mkdir -p "$tgt_dir"
    fi
done

# Process each file and copy it to the corresponding target location.
find "$SRC_DIR" -type f | while IFS= read -r src_file; do
    rel_path="${src_file#$SRC_DIR/}"
    tgt_file="$TGT_DIR/$rel_path"
    tgt_dir=$(dirname "$tgt_file")

    # Ensure the target subdirectory exists.
    if [ ! -d "$tgt_dir" ]; then
        run_action "Create Directory: $tgt_dir" mkdir -p "$tgt_dir"
    fi

    # If the target file exists, back it up.
    if [ -f "$tgt_file" ]; then
        if [ "$BACKUP_SEPARATE" = true ]; then
            backup_file="$BACKUP_DIR/$rel_path"
            backup_dir=$(dirname "$backup_file")
            run_action "Create Directory: $backup_dir" mkdir -p "$backup_dir"
            run_action "Backup: $tgt_file -> $backup_file" cp "$tgt_file" "$backup_file"
        else
            backup_file="${tgt_file}${BACKUP_FILE_SUFFIX}"
            run_action "Backup: $tgt_file -> $backup_file" cp "$tgt_file" "$backup_file"
        fi
    fi

    # Copy the source file to the target location.
    run_action "Copy: $src_file -> $tgt_file" cp "$src_file" "$tgt_file"
done

echo "Finished deploying files: $SRC_DIR -> $TGT_DIR"
