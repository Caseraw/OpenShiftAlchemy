#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/RHACM-credentials-aws"
KUSTOMIZE_ASSETS="$KUSTOMIZE_BASE/assets-temporary"
ASSETS_BYO="$PROJECT_DIR/assets-byo"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Create a temporary assets directory
mkdir -p $KUSTOMIZE_ASSETS

# Copy required external files into the temp directory
cp "$ASSETS_BYO/pull-secret/pull-secret.txt" "$KUSTOMIZE_ASSETS/pull-secret.txt"
cp "$ASSETS_BYO/ssh-keys/id_rsa" "$KUSTOMIZE_ASSETS/id_rsa"
cp "$ASSETS_BYO/ssh-keys/id_rsa.pub" "$KUSTOMIZE_ASSETS/id_rsa.pub"
cp "$ASSETS_BYO/aws-creds/bundle.env" "$KUSTOMIZE_ASSETS/bundle.env"

# Run Kustomize build and apply to OpenShift
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Cleanup: Remove the temporary directory
rm -rf "$KUSTOMIZE_ASSETS"

show_msg "show-date" "INFO" "Kustomize build and apply completed successfully."
