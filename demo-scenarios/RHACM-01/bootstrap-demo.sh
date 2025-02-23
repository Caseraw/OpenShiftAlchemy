#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Login on OpenShift RHACM cluster
source "$SCRIPT_DIR/oc-cli-login.sh"

# Setup OpenShift groups
source "$SCRIPT_DIR/setup-openshift-groups.sh"

# Setup OpenShift GitOps Operator
source "$SCRIPT_DIR/setup-openshift-gitops.sh"

# Setup OpenShift GitOps cluster
source "$SCRIPT_DIR/setup-rhacm-openshift-gitops-cluster.sh"

# Setup OpenShift Pipelines Operator
source "$SCRIPT_DIR/setup-openshift-pipelines.sh"

# Setup OpenShift Console configuration
source "$SCRIPT_DIR/setup-openshift-console-config.sh"

# Setup RHACM MultiCluster Observability
source "$SCRIPT_DIR/setup-rhacm-observability-operator.sh"

# Setup RHACM sample policies
source "$SCRIPT_DIR/setup-rhacm-sample-policies.sh"

# Setup RHACM credentials for AWS clusters
source "$SCRIPT_DIR/setup-rhacm-credentials-aws.sh"

# Setup 3 AWS managed clusters with RHACM
source "$SCRIPT_DIR/setup-rhacm-managed-cluster-aws.sh"

# Setup RHACM Rocket Chat application
source "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"

# Setup RHACM Application OpenShift Pipelines
source "$SCRIPT_DIR/RHACM-application-openshift-pipelines"

# Setup RHACM Application Color Game Challenge
source "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"
