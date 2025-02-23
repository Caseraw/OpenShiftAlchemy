#!/bin/bash

# Ensure oc CLI is installed
if ! command -v oc &> /dev/null; then
    echo "Error: The 'oc' command is not installed. Please install the OpenShift CLI and try again."
    exit 1
fi

# Check if already logged in
if oc whoami &> /dev/null; then
    CURRENT_USER=$(oc whoami)
    CURRENT_CLUSTER=$(oc whoami --show-server)
    echo "Already logged into OpenShift cluster."
    echo "User: $CURRENT_USER"
    echo "Cluster: $CURRENT_CLUSTER"

    # Ask if the user wants to re-login
    read -p "Do you want to log in again? (y/N): " RELOGIN
    if [[ ! "$RELOGIN" =~ ^[Yy]$ ]]; then
        echo "Keeping the existing session and continuing execution..."
    else
        # Prompt for OpenShift cluster details
        read -p "Enter OpenShift API URL (e.g., https://api.openshift.example.com:6443): " OC_API
        read -p "Enter OpenShift Username: " OC_USER
        read -s -p "Enter OpenShift Password: " OC_PASS
        echo

        # Attempt to log in
        echo "Logging into OpenShift cluster..."
        if oc login "$OC_API" -u "$OC_USER" -p "$OC_PASS" --insecure-skip-tls-verify; then
            echo "Login successful!"
            echo "You are now logged into the OpenShift cluster."
        else
            echo "Error: Login failed. Please check your credentials and API URL."
            exit 1
        fi
    fi
else
    # User is not logged in, prompt for credentials
    read -p "Enter OpenShift API URL (e.g., https://api.openshift.example.com:6443): " OC_API
    read -p "Enter OpenShift Username: " OC_USER
    read -s -p "Enter OpenShift Password: " OC_PASS
    echo

    # Attempt to log in
    echo "Logging into OpenShift cluster..."
    if oc login "$OC_API" -u "$OC_USER" -p "$OC_PASS" --insecure-skip-tls-verify; then
        echo "Login successful!"
        echo "You are now logged into the OpenShift cluster."
    else
        echo "Error: Login failed. Please check your credentials and API URL."
        exit 1
    fi
fi

# Confirm current user and cluster
echo "Current user details:"
oc whoami
echo "Current cluster:"
oc whoami --show-server
