#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Set the current context to the local cluster
show_msg "show-date" "INFO" "Setting the current context to the local cluster"
oc patch managedcluster local-cluster --patch '{"metadata": {"labels": {"rhdp_usage": "development"}}}' --type=merge

show_msg "show-date" "INFO" "Done running the prerequisites"
