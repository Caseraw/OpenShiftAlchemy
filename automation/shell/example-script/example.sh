#!/bin/env bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"

# Load additional functions
source "$SCRIPT_DIR/lib/show_msg.sh"
source "$SCRIPT_DIR/lib/run_cmd.sh"

# Show message
show_msg "show-date" "INFO" "Title of the example message" "Description of example message" "Body of the example message"

# Run command
run_cmd --retries 3 --pause 5 -- date
