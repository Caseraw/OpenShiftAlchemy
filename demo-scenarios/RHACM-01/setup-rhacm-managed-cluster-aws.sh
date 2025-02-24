#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
ASSETS_BYO="$PROJECT_DIR/assets-byo"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Load AWS credentials & base domain
source "$PROJECT_DIR/assets-byo/aws-creds/aws-cli.env"
source "$PROJECT_DIR/assets-byo/aws-creds/basedomain.env"

# Define cluster names and labels
CLUSTERS=("aws-cluster-01" "aws-cluster-02" "aws-cluster-03")
declare -A CLUSTER_LABELS
CLUSTER_LABELS["aws-cluster-01"]="environment: dev"
CLUSTER_LABELS["aws-cluster-02"]="environment: staging"
CLUSTER_LABELS["aws-cluster-03"]="environment: prod"

# Define cluster regions
# Default region, already set => AWS_DEFAULT_REGION
declare -A CLUSTER_REGION
CLUSTER_REGION["aws-cluster-01"]="$AWS_DEFAULT_REGION"
CLUSTER_REGION["aws-cluster-02"]="eu-west-2"
CLUSTER_REGION["aws-cluster-03"]="eu-west-3"

# Read static files once
mapfile -t SSH_PRIV_KEY_LINES < "$ASSETS_BYO/ssh-keys/id_rsa"
mapfile -t SSH_PUB_KEY_LINES < "$ASSETS_BYO/ssh-keys/id_rsa.pub"
mapfile -t PULL_SECRET_LINES < "$ASSETS_BYO/pull-secret/pull-secret.txt"

SSH_PRIV_KEY=$(printf "%s\n" "${SSH_PRIV_KEY_LINES[@]}")
SSH_PUB_KEY=$(printf "%s\n" "${SSH_PUB_KEY_LINES[@]}")
PULL_SECRET=$(printf "%s\n" "${PULL_SECRET_LINES[@]}")

# Function to deploy a cluster
deploy_cluster() {
    local AWS_CLUSTER_NAME=$1
    local AWS_DEFAULT_REGION="${CLUSTER_REGION[$AWS_CLUSTER_NAME]}"
    local MANAGED_CLUSTER_LABELS="${CLUSTER_LABELS[$AWS_CLUSTER_NAME]}"

    show_msg "show-date" "INFO" "🚀" "Deploying cluster" "$AWS_CLUSTER_NAME"

    INSTALL_CONFIG_YAML=$(cat <<EOF
apiVersion: v1
metadata:
  name: $AWS_CLUSTER_NAME
baseDomain: $baseDomain
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 4000
        size: 100
        type: io1
      type: m5.xlarge
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
  platform:
    aws:
      rootVolume:
        iops: 2000
        size: 100
        type: io1
      type: m5.xlarge
networking:
  networkType: OVNKubernetes
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  serviceNetwork:
  - 172.30.0.0/16
platform:
  aws:
    region: $AWS_DEFAULT_REGION
pullSecret: "" # skip, hive will inject based on its secrets
sshKey: |-
    $SSH_PUB_KEY
EOF
)

    INSTALL_CONFIG_YAML_B64=$(echo "$INSTALL_CONFIG_YAML" | base64 -w 0)

    # Apply cluster deployment YAML
    # cat <<EOF > $AWS_CLUSTER_NAME.txt
    oc apply -f - <<EOF
kind: Namespace
apiVersion: v1
metadata:
  name: $AWS_CLUSTER_NAME
  labels:
    # cluster.open-cluster-management.io/managedCluster: $AWS_CLUSTER_NAME
    kubernetes.io/metadata.name: $AWS_CLUSTER_NAME
    # open-cluster-management.io/cluster-name: $AWS_CLUSTER_NAME
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: $AWS_CLUSTER_NAME
  namespace: $AWS_CLUSTER_NAME
  labels:
    cloud: AWS
    region: $AWS_DEFAULT_REGION
    vendor: OpenShift
spec:
  baseDomain: $baseDomain
  clusterName: $AWS_CLUSTER_NAME
  controlPlaneConfig:
    servingCertificates: {}
  installAttemptsLimit: 1
  installed: false
  platform:
    aws:
      credentialsSecretRef:
        name: $AWS_CLUSTER_NAME-aws-creds
      region: $AWS_DEFAULT_REGION
  provisioning:
    installConfigSecretRef:
      name: $AWS_CLUSTER_NAME-install-config
    sshPrivateKeySecretRef:
      name: $AWS_CLUSTER_NAME-ssh-private-key
    imageSetRef:
      #quay.io/openshift-release-dev/ocp-release:4.17.17-multi
      name: img4.17.17-multi-appsub
  pullSecretRef:
    name: $AWS_CLUSTER_NAME-pull-secret
---
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  labels:
    cloud: Amazon
    region: $AWS_DEFAULT_REGION
    name: $AWS_CLUSTER_NAME
    vendor: OpenShift
$(echo "$MANAGED_CLUSTER_LABELS" | awk 'NF {print "    " $0}')
  name: $AWS_CLUSTER_NAME
spec:
  hubAcceptsClient: true
---
apiVersion: hive.openshift.io/v1
kind: MachinePool
metadata:
  name: $AWS_CLUSTER_NAME-worker
  namespace: $AWS_CLUSTER_NAME
spec:
  clusterDeploymentRef:
    name: $AWS_CLUSTER_NAME
  name: worker
  platform:
    aws:
      rootVolume:
        iops: 2000
        size: 100
        type: io1
      type: m5.xlarge
  replicas: 3
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-pull-secret
  namespace: $AWS_CLUSTER_NAME
stringData:
  .dockerconfigjson: |-
    $PULL_SECRET
type: kubernetes.io/dockerconfigjson
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-install-config
  namespace: $AWS_CLUSTER_NAME
type: Opaque
data:
  # Base64 encoding of install-config yaml
  install-config.yaml: $INSTALL_CONFIG_YAML_B64
---
apiVersion: v1
kind: Secret
metadata:
  name: $AWS_CLUSTER_NAME-ssh-private-key
  namespace: $AWS_CLUSTER_NAME
stringData:
  ssh-privatekey: |-
$(echo "$SSH_PRIV_KEY" | sed 's/^/    /')
type: Opaque
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: $AWS_CLUSTER_NAME-aws-creds
  namespace: $AWS_CLUSTER_NAME
stringData:
  aws_access_key_id: $AWS_ACCESS_KEY_ID
  aws_secret_access_key: $AWS_SECRET_ACCESS_KEY
---
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: $AWS_CLUSTER_NAME
  namespace: $AWS_CLUSTER_NAME
spec:
  clusterName: $AWS_CLUSTER_NAME
  clusterNamespace: $AWS_CLUSTER_NAME
  clusterLabels:
    cloud: Amazon
    vendor: OpenShift
  applicationManager:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  certPolicyController:
    enabled: true
EOF
  
    sleep 5
    show_msg "show-date" "INFO" "✅" "Cluster $AWS_CLUSTER_NAME" "Deployed successfully!"
}

# 🚀 Deploy all clusters in the list
for CLUSTER in "${CLUSTERS[@]}"; do
    deploy_cluster "$CLUSTER"
done
