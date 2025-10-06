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

# dbt Cloud
export DBT_CLOUD_API_TOKEN=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=credential --reveal)
export DBT_CLOUD_ACCOUNT_ID=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=account_id)
export DBT_PROJECT_DIR=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=project_dir)

# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN=$(op item get "DA Agent Hub - GitHub PAT" --vault="$VAULT" --fields label=credential --reveal)

# AWS Credentials
export AWS_ACCESS_KEY_ID=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=username)
export AWS_SECRET_ACCESS_KEY=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=password --reveal)
export AWS_REGION=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=region)
export AWS_DEFAULT_REGION=$AWS_REGION

# Snowflake
export SNOWFLAKE_ACCOUNT=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=account 2>/dev/null || echo "")
export SNOWFLAKE_USER=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=username 2>/dev/null || echo "")
export SNOWFLAKE_PASSWORD=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=password --reveal 2>/dev/null || echo "")
export SNOWFLAKE_DATABASE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=database 2>/dev/null || echo "")
export SNOWFLAKE_SCHEMA=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=schema 2>/dev/null || echo "")
export SNOWFLAKE_WAREHOUSE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=warehouse 2>/dev/null || echo "")
export SNOWFLAKE_ROLE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=role 2>/dev/null || echo "")
export SNOWFLAKE_AUTH_METHOD=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=auth_method 2>/dev/null || echo "oauth")

# Note: Snowflake PAT is used as password (SNOWFLAKE_PASSWORD)
# Most tools expect it in the password field, not as a separate token

# Verify critical secrets were loaded
if [ -z "$DBT_CLOUD_API_TOKEN" ] || [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo -e "${RED}❌ Failed to load critical secrets from 1Password${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Secrets loaded successfully!${NC}"
echo ""
echo "Environment variables set:"
echo "  DBT_CLOUD_API_TOKEN: ${DBT_CLOUD_API_TOKEN:0:20}..."
echo "  DBT_CLOUD_ACCOUNT_ID: $DBT_CLOUD_ACCOUNT_ID"
echo "  DBT_PROJECT_DIR: $DBT_PROJECT_DIR"
echo "  GITHUB_PERSONAL_ACCESS_TOKEN: ${GITHUB_PERSONAL_ACCESS_TOKEN:0:15}..."
echo "  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:10}..."
echo "  AWS_REGION: $AWS_REGION"
if [ -n "$SNOWFLAKE_ACCOUNT" ] && [ "$SNOWFLAKE_ACCOUNT" != "<your_snowflake_account>" ]; then
    echo "  SNOWFLAKE_ACCOUNT: $SNOWFLAKE_ACCOUNT"
    echo "  SNOWFLAKE_USER: $SNOWFLAKE_USER"
    echo "  SNOWFLAKE_DATABASE: $SNOWFLAKE_DATABASE"
    echo "  SNOWFLAKE_WAREHOUSE: $SNOWFLAKE_WAREHOUSE"
    echo "  SNOWFLAKE_AUTH_METHOD: $SNOWFLAKE_AUTH_METHOD"
fi
echo ""
echo -e "${YELLOW}💡 Tip: Source this script to use secrets in your shell:${NC}"
echo "  source ~/dotfiles/load-secrets-from-1password.sh"
