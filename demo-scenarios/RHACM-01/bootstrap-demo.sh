#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Login on OpenShift RHACM cluster
source "$SCRIPT_DIR/login-rhamc-oc-cli.sh"

# Setup RHACM credentials for AWS
source "$SCRIPT_DIR/setup-rhacm-credentials-aws.sh"

# Setup RHACM managed cluster
# source "$SCRIPT_DIR/setup-rhacm-managed-cluster-aws.sh"

# Setup OpenShift groups
source "$SCRIPT_DIR/setup-openshift-groups.sh"

# Setup OpenShift GitOps Operator
source "$SCRIPT_DIR/setup-openshift-gitops.sh"

# Setup OpenShift Pipelines Operator
source "$SCRIPT_DIR/setup-openshift-pipelines.sh"

# Setup OpenShift Console configuration
source "$SCRIPT_DIR/setup-openshift-console-config.sh"

# Setup OpenShift GitOps cluster
source "$SCRIPT_DIR/setup-rhacm-openshift-gitops-cluster.sh"

# Setup Rocket Chat application
source "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"
