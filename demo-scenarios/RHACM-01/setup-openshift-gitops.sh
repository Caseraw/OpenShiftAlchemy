#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/openshift-gitops"

# Run Kustomize build and apply to OpenShift
echo "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

echo "Kustomize build and apply completed successfully."

echo "OpenShift GitOps ArgoCD instance state"

sleep 20

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
