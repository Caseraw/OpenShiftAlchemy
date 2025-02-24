#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-gitops"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Run Kustomize build and apply to OpenShift
show_msg "show-date" "INFO" "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

show_msg "show-date" "INFO" "Kustomize build and apply completed successfully."

# Wait for OpenShift GitOps ArgoCD instance to be ready
show_msg "show-date" "INFO" "Check for OpenShift GitOps ArgoCD instance state"

run_cmd --infinite -- oc -n openshift-gitops-operator wait ClusterServiceVersion -l olm.managed=true --for=jsonpath='{.status.phase}'=Succeeded
run_cmd --infinite -- oc -n openshift-gitops wait ClusterServiceVersion -l olm.copiedFrom=openshift-gitops-operator --for=jsonpath='{.status.phase}'=Succeeded

oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.phase}'=Available --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationController}'=Running --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.applicationSetController}'=Running --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.redis}'=Running --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.repo}'=Running --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.server}'=Running --timeout=900s
oc -n openshift-gitops wait ArgoCD openshift-gitops --for=jsonpath='{.status.sso}'=Running --timeout=900s

pods=$(oc -n openshift-gitops get pod --no-headers -o custom-columns=NAME:.metadata.name)

for pod in ${pods}; do
  oc -n openshift-gitops wait pod $pod --for=jsonpath='{.status.phase}'=Running
  oc -n openshift-gitops wait pod $pod --for=condition=Ready
done

show_msg "show-date" "INFO" "OpenShift GitOps ArgoCD instance ready"
