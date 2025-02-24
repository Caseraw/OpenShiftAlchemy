#!/bin/bash

# Define directories
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"
ASSETS_BYO="$PROJECT_DIR/assets-byo"

AWS_CREDS_DIR="$ASSETS_BYO/aws-creds"
PULL_SECRET_DIR="$ASSETS_BYO/pull-secret"
SSH_KEYS_DIR="$ASSETS_BYO/ssh-keys"

# Load additional functions
source "$PROJECT_DIR/automation/shell/lib/show_msg.sh"
source "$PROJECT_DIR/automation/shell/lib/run_cmd.sh"

# Define required files as arrays (scalable for future additions)
AWS_CREDS_FILES=(
    "accesskeyid.env"
    "aws-cli.env"
    "basedomain.env"
    "bundle.env"
    "secretaccesskey.env"
)

PULL_SECRET_FILES=(
    "pull-secret.txt"
)

SSH_KEY_FILES=(
    "id_rsa"
    "id_rsa.pub"
)

# Function to check if required files exist
check_files() {
    local folder=$1
    shift
    local files=("$@")
    local missing_files=()

    for file in "${files[@]}"; do
        if [[ ! -f "$folder/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -eq 0 ]]; then
        return 0  # All files exist
    else
        show_msg "show-date" "CRITICAL" "❌" "Missing files in $folder" "${missing_files[*]}"
        return 1  # Some files are missing
    fi
}

# Function to prompt user and run setup script
prompt_and_run() {
    local folder=$1
    local setup_script=$2
 
    show_msg "show-date" "WARNING" "⚠️" "Required files in '$folder' are missing" "Do you want to create them now? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        show_msg "show-date" "INFO" "Running setup script" "$setup_script"
        bash "$folder/$setup_script"
    else
        show_msg "show-date" "CRITICAL" "❌" "Cannot proceed without required files" "Exiting"
        exit 1
    fi
}

# Step 1: Check AWS Credentials
check_files "$AWS_CREDS_DIR" "${AWS_CREDS_FILES[@]}" || prompt_and_run "$AWS_CREDS_DIR" "setup-aws-creds.sh"

# Step 2: Check Pull Secret
check_files "$PULL_SECRET_DIR" "${PULL_SECRET_FILES[@]}" || prompt_and_run "$PULL_SECRET_DIR" "setup-pull-secret.sh"

# Step 3: Check SSH Keys
check_files "$SSH_KEYS_DIR" "${SSH_KEY_FILES[@]}" || prompt_and_run "$SSH_KEYS_DIR" "generate-ssh-keypair.sh"

# Step 4: Final Verification
echo "🔄 Re-checking prerequisites..."
if check_files "$AWS_CREDS_DIR" "${AWS_CREDS_FILES[@]}" && \
   check_files "$PULL_SECRET_DIR" "${PULL_SECRET_FILES[@]}" && \
   check_files "$SSH_KEYS_DIR" "${SSH_KEY_FILES[@]}"; then
    echo " "
    show_msg "show-date" "CRITICAL" "✅" "All prerequisites met" "Proceeding..."
else
    show_msg "show-date" "CRITICAL" "❌" "Some files are still missing" "Exiting"
    exit 1
fi
