#!/bin/env bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load additional functions
source "$SCRIPT_DIR/../../automation/shell/lib/show_msg.sh"
source "$SCRIPT_DIR/../../automation/shell/lib/run_cmd.sh"

# Define SSH key filenames
KEY_FILE="$SCRIPT_DIR/id_rsa"
PUB_KEY_FILE="$KEY_FILE.pub"

# Check if SSH keypair already exists
if [[ -f "$KEY_FILE" && -f "$PUB_KEY_FILE" ]]; then
    show_msg "show-date" "INFO" "SSH Keypair Exists" "Skipping creation" "Files: $KEY_FILE, $PUB_KEY_FILE"
else
    # Show message about creation
    show_msg "show-date" "INFO" "Creating SSH Keypair" "Type RSA, Size 4096" "Comment: demo-ssh-key, Filename: id_rsa"

    # Run command to generate SSH keypair
    run_cmd -- ssh-keygen -t rsa -b 4096 -C "demo-ssh-key" -f "$KEY_FILE" -N "" -q
fi
