#!/bin/bash

# Load DA Agent Hub Secrets from 1Password GRC Vault
# This script fetches secrets from 1Password and exports them as environment variables

set -e  # Exit on error

VAULT="GRC"
ITEM_NAME="DA Agent Hub - dbt Cloud"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 Loading DA Agent Hub secrets from 1Password...${NC}"

# Check if 1Password CLI is installed
if ! command -v op &> /dev/null; then
    echo -e "${RED}❌ 1Password CLI not installed${NC}"
    echo "Install with: brew install --cask 1password-cli"
    exit 1
fi

# Check if we can access 1Password
if ! op vault list &> /dev/null; then
    echo -e "${RED}❌ Cannot access 1Password${NC}"
    echo "Make sure:"
    echo "  1. 1Password desktop app is running"
    echo "  2. CLI integration is enabled in Settings → Developer"
    exit 1
fi

# Fetch secrets from 1Password
echo "📥 Fetching secrets from vault: $VAULT"

export DBT_CLOUD_API_TOKEN=$(op item get "$ITEM_NAME" --vault="$VAULT" --fields label=credential --reveal)
export DBT_CLOUD_ACCOUNT_ID=$(op item get "$ITEM_NAME" --vault="$VAULT" --fields label=account_id)
export DBT_PROJECT_DIR=$(op item get "$ITEM_NAME" --vault="$VAULT" --fields label=project_dir)

# Verify secrets were loaded
if [ -z "$DBT_CLOUD_API_TOKEN" ] || [ -z "$DBT_CLOUD_ACCOUNT_ID" ]; then
    echo -e "${RED}❌ Failed to load secrets from 1Password${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Secrets loaded successfully!${NC}"
echo ""
echo "Environment variables set:"
echo "  DBT_CLOUD_API_TOKEN: ${DBT_CLOUD_API_TOKEN:0:20}..."
echo "  DBT_CLOUD_ACCOUNT_ID: $DBT_CLOUD_ACCOUNT_ID"
echo "  DBT_PROJECT_DIR: $DBT_PROJECT_DIR"
echo ""
echo -e "${YELLOW}💡 Tip: Source this script to use secrets in your shell:${NC}"
echo "  source ~/dotfiles/load-secrets-from-1password.sh"
