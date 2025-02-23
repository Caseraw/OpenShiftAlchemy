#!/bin/bash

# Define paths
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
KUSTOMIZE_BASE="$PROJECT_DIR/assets/kustomize/base/RHACM-multicluster-observability"
KUSTOMIZE_ASSETS="$KUSTOMIZE_BASE/assets-temporary"
ASSETS_BYO="$PROJECT_DIR/assets-byo"

# Set some variables
source "$PROJECT_DIR/assets-byo/aws-creds/aws-cli.env"
GRAFANA_S3_BUCKET=grafana-$GUID_DOMAIN

# Run AWS CLI to configure AWS credentials
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION

# Create AWS S3 Bucket for grafana
aws s3 mb s3://$GRAFANA_S3_BUCKET

# Create a temporary assets directory
mkdir -p $KUSTOMIZE_ASSETS

# Copy required external files into the temp directory
cp "$ASSETS_BYO/pull-secret/pull-secret.txt" "$KUSTOMIZE_ASSETS/pull-secret.txt"

# Run Kustomize build and apply to OpenShift
echo "Running Kustomize build..."
kustomize build "$KUSTOMIZE_BASE" | oc apply -f -

# Create Thanos object storage secret
oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: $GRAFANA_S3_BUCKET
      endpoint: s3.amazonaws.com
      insecure: false
      access_key: $AWS_ACCESS_KEY_ID
      secret_key: $AWS_DEFAULT_REGION
EOF

# Cleanup: Remove the temporary directory
rm -rf "$KUSTOMIZE_ASSETS"
