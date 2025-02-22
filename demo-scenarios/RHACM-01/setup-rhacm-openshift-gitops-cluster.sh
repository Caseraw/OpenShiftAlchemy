#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/RHACM-openshift-gitops-cluster"

# Run Kustomize build and apply to OpenShift
echo "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

echo "Kustomize build and apply completed successfully."
