# DA Agent Hub Secrets Inventory

All secrets stored in **1Password GRC Vault** and automatically loaded via `load-secrets-from-1password.sh`.

## Stored Items in GRC Vault

### 1. DA Agent Hub - dbt Cloud
**Category**: API Credential
**Fields**:
- `credential`: dbt Cloud API Token
- `account_id`: 2672
- `project_dir`: ~/da-agent-hub/repos/dbt_cloud

**Environment Variables**:
- `DBT_CLOUD_API_TOKEN`
- `DBT_CLOUD_ACCOUNT_ID`
- `DBT_PROJECT_DIR`

---

### 2. DA Agent Hub - GitHub PAT
**Category**: API Credential
**Fields**:
- `credential`: GitHub Personal Access Token
- `scopes`: repo, read:org, read:project
- `purpose`: MCP server GitHub integration

**Environment Variables**:
- `GITHUB_PERSONAL_ACCESS_TOKEN`

**Used In**: `.claude/mcp.json` (github MCP server)

---

### 3. DA Agent Hub - AWS Credentials
**Category**: Login
**Fields**:
- `username`: AWS Access Key ID (AKIAR4J53PIEPQWTVNOU)
- `password`: AWS Secret Access Key
- `region`: us-west-2
- `profile`: default

**Environment Variables**:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_DEFAULT_REGION`

**Used In**: AWS CLI, aws-api MCP server

---

### 4. DA Agent Hub - Snowflake
**Category**: Database
**Fields**:
- `account`: FC41459
- `username`: CLAUDE
- `password`: Personal Access Token (PAT) - used as password in connections
- `database`: ANALYTICS_DW
- `schema`: PROD_SALES_DM
- `warehouse`: SLATECO_WH (default warehouse for CLAUDE user)
- `role`: BUSINESS_USER (default role, has 4 granted roles)
- `auth_method`: password

**Environment Variables**:
- `SNOWFLAKE_ACCOUNT` = FC41459
- `SNOWFLAKE_USER` = CLAUDE
- `SNOWFLAKE_PASSWORD` = PAT (use this in connection strings)
- `SNOWFLAKE_DATABASE` = ANALYTICS_DW
- `SNOWFLAKE_SCHEMA` = PROD_SALES_DM
- `SNOWFLAKE_WAREHOUSE` = SLATECO_WH
- `SNOWFLAKE_ROLE` = BUSINESS_USER
- `SNOWFLAKE_AUTH_METHOD` = password

**Connection Verified**: ✅ Tested successfully via Python snowflake-connector
**Used In**: `config/snowflake_tools_config.yaml`, snowflake-mcp server

**Important**: Snowflake PAT is used in the `password` field (not `token` or with `oauth` authenticator)

---

## Access Instructions

### View All DA Agent Hub Secrets
```bash
op item list --vault="GRC" --tags="da-agent-hub"
```

### View Specific Item
```bash
op item get "DA Agent Hub - dbt Cloud" --vault="GRC"
op item get "DA Agent Hub - GitHub PAT" --vault="GRC"
op item get "DA Agent Hub - AWS Credentials" --vault="GRC"
op item get "DA Agent Hub - Snowflake" --vault="GRC"
```

### Load All Secrets
```bash
source ~/dotfiles/load-secrets-from-1password.sh
```

## Security Status

✅ **No hardcoded secrets in git repositories**
✅ **All secrets centrally managed in 1Password**
✅ **Automatic sync across all machines**
✅ **Biometric authentication required**
✅ **Audit trail for all access**

## Connection Test Results

✅ **Snowflake Connection Verified**: October 6, 2025
- Account: FC41459.snowflakecomputing.com
- User: CLAUDE
- Role: BUSINESS_USER
- Warehouse: SLATECO_WH
- Database: ANALYTICS_DW
- Auth: PAT via password parameter

## Last Updated
- Account identifier corrected: `41459` → `FC41459`
- Warehouse updated: `TABLEAU_WH` → `SLATECO_WH`
- Role updated: `DEVELOPER` → `BUSINESS_USER`
- Auth method clarified: PAT used as `password` parameter
- All updates: October 6, 2025
