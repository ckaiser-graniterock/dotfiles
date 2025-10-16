#!/bin/bash

# Load DA Agent Hub Secrets from 1Password GRC Vault
# This script fetches secrets from 1Password and exports them as environment variables
# Includes caching to reduce 1Password API calls (24-hour cache)

set -e  # Exit on error

VAULT="GRC"
ITEM_NAME="DA Agent Hub - dbt Cloud"
CACHE_FILE="$HOME/.da-agent-hub-secrets-cache"
CACHE_DURATION_SECONDS=$((24 * 60 * 60))  # 24 hours

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)))
    if [ $CACHE_AGE -lt $CACHE_DURATION_SECONDS ]; then
        echo -e "${GREEN}🔐 Loading DA Agent Hub secrets from cache ($(($CACHE_DURATION_SECONDS - $CACHE_AGE)) seconds remaining)...${NC}"
        source "$CACHE_FILE"
        echo -e "${GREEN}✅ Secrets loaded from cache!${NC}"
        return 0 2>/dev/null || exit 0
    fi
fi

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
export SNOWFLAKE_PRIVATE_KEY_PATH=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=SNOWFLAKE_PRIVATE_KEY_PATH 2>/dev/null || echo "")
export SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=SNOWFLAKE_PRIVATE_KEY_PASSPHRASE --reveal 2>/dev/null || echo "")

# Note: Snowflake PAT is used as password (SNOWFLAKE_PASSWORD)
# Most tools expect it in the password field, not as a separate token

# Claude Code
# DISABLED: Using claude.ai auth instead of API key to avoid conflicts
# export ANTHROPIC_API_KEY=$(op item get "Claude Code - API Key" --vault="$VAULT" --fields label=credential --reveal 2>/dev/null || echo "")

# Slack
export SLACK_BOT_TOKEN=$(op item get "DA Agent Hub - Slack Bot Token" --vault="$VAULT" --fields label=credential --reveal 2>/dev/null || echo "")
export SLACK_TEAM_ID=$(op item get "DA Agent Hub - Slack Bot Token" --vault="$VAULT" --fields label=team_id --reveal 2>/dev/null || echo "")

# Orchestra orchestration platform
export ORCHESTRA_API_KEY=$(op item get "DA Agent Hub - Orchestra" --vault="$VAULT" --fields label=credential --reveal 2>/dev/null || echo "")

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
# DISABLED: Using claude.ai auth instead
# if [ -n "$ANTHROPIC_API_KEY" ]; then
#     echo "  ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:20}..."
# fi
if [ -n "$SLACK_BOT_TOKEN" ]; then
    echo "  SLACK_BOT_TOKEN: ${SLACK_BOT_TOKEN:0:15}..."
    echo "  SLACK_TEAM_ID: $SLACK_TEAM_ID"
fi
if [ -n "$SNOWFLAKE_ACCOUNT" ] && [ "$SNOWFLAKE_ACCOUNT" != "<your_snowflake_account>" ]; then
    echo "  SNOWFLAKE_ACCOUNT: $SNOWFLAKE_ACCOUNT"
    echo "  SNOWFLAKE_USER: $SNOWFLAKE_USER"
    echo "  SNOWFLAKE_DATABASE: $SNOWFLAKE_DATABASE"
    echo "  SNOWFLAKE_WAREHOUSE: $SNOWFLAKE_WAREHOUSE"
    echo "  SNOWFLAKE_AUTH_METHOD: $SNOWFLAKE_AUTH_METHOD"
fi
if [ -n "$ORCHESTRA_API_KEY" ]; then
    echo "  ORCHESTRA_API_KEY: ${ORCHESTRA_API_KEY:0:15}..."
fi
echo ""
echo -e "${YELLOW}💡 Tip: Source this script to use secrets in your shell:${NC}"
echo "  source ~/dotfiles/load-secrets-from-1password.sh"

# Write secrets to cache file (secure permissions)
cat > "$CACHE_FILE" <<EOF
# DA Agent Hub Secrets Cache
# Auto-generated by load-secrets-from-1password.sh
# This file is gitignored and has secure permissions (600)
export DBT_CLOUD_API_TOKEN="$DBT_CLOUD_API_TOKEN"
export DBT_CLOUD_ACCOUNT_ID="$DBT_CLOUD_ACCOUNT_ID"
export DBT_PROJECT_DIR="$DBT_PROJECT_DIR"
export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_REGION="$AWS_REGION"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
export SNOWFLAKE_ACCOUNT="$SNOWFLAKE_ACCOUNT"
export SNOWFLAKE_USER="$SNOWFLAKE_USER"
export SNOWFLAKE_PASSWORD="$SNOWFLAKE_PASSWORD"
export SNOWFLAKE_DATABASE="$SNOWFLAKE_DATABASE"
export SNOWFLAKE_SCHEMA="$SNOWFLAKE_SCHEMA"
export SNOWFLAKE_WAREHOUSE="$SNOWFLAKE_WAREHOUSE"
export SNOWFLAKE_ROLE="$SNOWFLAKE_ROLE"
export SNOWFLAKE_AUTH_METHOD="$SNOWFLAKE_AUTH_METHOD"
export SNOWFLAKE_PRIVATE_KEY_PATH="$SNOWFLAKE_PRIVATE_KEY_PATH"
export SNOWFLAKE_PRIVATE_KEY_PASSPHRASE="$SNOWFLAKE_PRIVATE_KEY_PASSPHRASE"
export SLACK_BOT_TOKEN="$SLACK_BOT_TOKEN"
export SLACK_TEAM_ID="$SLACK_TEAM_ID"
export ORCHESTRA_API_KEY="$ORCHESTRA_API_KEY"
EOF

# Secure the cache file (owner read/write only)
chmod 600 "$CACHE_FILE"
echo -e "${GREEN}📦 Secrets cached for 24 hours${NC}"
