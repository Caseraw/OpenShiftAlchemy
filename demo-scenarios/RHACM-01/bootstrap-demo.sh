#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Bootstrap prerequisites
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/bootstrap-prerequisite.sh"
source "$SCRIPT_DIR/bootstrap-prerequisite.sh"

# Login on OpenShift RHACM cluster
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/oc-cli-login.sh"
source "$SCRIPT_DIR/oc-cli-login.sh"

# Setup OpenShift groups
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-openshift-groups.sh"
source "$SCRIPT_DIR/setup-openshift-groups.sh"

# Setup OpenShift GitOps Operator
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-openshift-gitops.sh"
source "$SCRIPT_DIR/setup-openshift-gitops.sh"

# Setup OpenShift GitOps cluster
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-openshift-gitops-cluster.sh"
source "$SCRIPT_DIR/setup-rhacm-openshift-gitops-cluster.sh"

# Setup OpenShift Pipelines Operator
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-openshift-pipelines.sh"
source "$SCRIPT_DIR/setup-openshift-pipelines.sh"

# Setup OpenShift Console configuration
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-openshift-console-config.sh"
source "$SCRIPT_DIR/setup-openshift-console-config.sh"

# Setup RHACM MultiCluster Observability
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-observability-operator.sh"
source "$SCRIPT_DIR/setup-rhacm-observability-operator.sh"

# Setup RHACM sample policies
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-sample-policies.sh"
source "$SCRIPT_DIR/setup-rhacm-sample-policies.sh"

# Setup RHACM credentials for AWS clusters
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-credentials-aws.sh"
source "$SCRIPT_DIR/setup-rhacm-credentials-aws.sh"

# Setup 3 AWS managed clusters with RHACM
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-managed-cluster-aws.sh"
source "$SCRIPT_DIR/setup-rhacm-managed-cluster-aws.sh"

# Setup RHACM Rocket Chat application
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"
source "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"

# Setup RHACM Application OpenShift Pipelines
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-application-openshift-pipelines.sh"
source "$SCRIPT_DIR/setup-application-openshift-pipelines.sh"

# Setup RHACM Application Color Game Challenge
show_msg "show-date" "INFO" "Running" "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"
source "$SCRIPT_DIR/setup-rhacm-application-rocket-chat.sh"
