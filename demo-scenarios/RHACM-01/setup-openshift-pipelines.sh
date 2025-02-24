#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-pipelines"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Run Kustomize build and apply to OpenShift
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

show_msg "show-date" "INFO" "Kustomize build and apply completed successfully."

# Wait for OpenShift Pipelines to be ready
show_msg "show-date" "INFO" "Check for OpenShift Pipelines state"

run_cmd --infinite -- oc -n openshift-operators wait ClusterServiceVersion -l olm.managed=true --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc get tektonconfigs config

oc -n openshift-operators wait pod -l app=openshift-pipelines-operator --for=jsonpath='{.status.phase}'=Running --timeout=900s
oc -n openshift-operators wait pod -l app=openshift-pipelines-operator --for=condition=Ready --timeout=900s

show_msg "show-date" "INFO" "OpenShift GitOps ArgoCD instance ready"
