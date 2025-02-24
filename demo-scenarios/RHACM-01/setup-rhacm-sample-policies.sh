#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Run Kustomize build and apply to OpenShift
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$PROJECT_DIR/sample-rhacm-policies" | oc apply -f -

show_msg "show-date" "INFO" "Kustomize build and apply completed successfully."
