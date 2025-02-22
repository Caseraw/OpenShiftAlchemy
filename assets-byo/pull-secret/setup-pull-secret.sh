#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PULL_SECRET_FILE="$SCRIPT_DIR/pull-secret.txt"

# Load additional functions
source "$SCRIPT_DIR/../../automation/shell/lib/show_msg.sh"
source "$SCRIPT_DIR/../../automation/shell/lib/run_cmd.sh"

# Function to check and confirm overwriting a file
confirm_overwrite() {
    local file="$1"

    if [[ -f "$file" ]]; then
        show_msg "show-date" "WARNING" "Existing file" "$file already exists" "Confirm to proceed if needed"
        read -p "Do you want to overwrite $file? (y/N): " CONFIRM

        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            return 0  # Overwrite file
        else
            show_msg "show-date" "INFO" "Skipped" "$file was not modified"
            return 1  # Skip file
        fi
    fi

    return 0  # File doesn't exist, create it
}

# Ask the user how they want to provide the pull-secret
echo "How would you like to provide the pull-secret?"
echo "1) Provide the file path"
echo "2) Manually enter the pull-secret"
read -p "Choose an option (1/2): " OPTION

PULL_SECRET_CONTENT=""

if [[ "$OPTION" == "1" ]]; then
    read -p "Enter the full path to the pull-secret file: " SOURCE_FILE

    if [[ -f "$SOURCE_FILE" ]]; then
        PULL_SECRET_CONTENT=$(cat "$SOURCE_FILE")
    else
        show_msg "show-date" "CRITICAL" "File not found" "The specified file does not exist."
        exit 1
    fi

elif [[ "$OPTION" == "2" ]]; then
    read -p "Enter the pull-secret as a minified JSON object: " PULL_SECRET_CONTENT
else
    show_msg "show-date" "CRITICAL" "Invalid selection" "Please enter either 1 or 2."
    exit 1
fi

# Handle pull-secret file creation based on user confirmation
if confirm_overwrite "$PULL_SECRET_FILE"; then
    echo "$PULL_SECRET_CONTENT" > "$PULL_SECRET_FILE"
    show_msg "show-date" "INFO" "Done" "Pull-secret file created/updated" "$PULL_SECRET_FILE"
fi
