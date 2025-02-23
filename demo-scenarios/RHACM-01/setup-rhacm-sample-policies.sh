#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run Kustomize build and apply to OpenShift
echo "Running Kustomize build..."
kustomize build "$PROJECT_DIR/sample-rhacm-policies" | oc apply -f -

echo "Kustomize build and apply completed successfully."
