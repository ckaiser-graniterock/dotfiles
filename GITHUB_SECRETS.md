# GitHub Secrets Setup Guide

This guide explains how to use GitHub Secrets to securely store environment variables for GitHub Actions workflows.

## Understanding GitHub Secrets

**What GitHub Secrets ARE:**
- Encrypted environment variables stored in GitHub
- Accessible in GitHub Actions workflows via `${{ secrets.SECRET_NAME }}`
- Secure for CI/CD pipelines, automated tasks, scheduled jobs
- Hidden from logs (GitHub automatically redacts secret values)

**What GitHub Secrets are NOT:**
- They do NOT replace local `.env` files
- They do NOT automatically populate your development environment
- They are ONLY available in GitHub Actions workflows

## Use Cases

✅ **Perfect for:**
- Automated dbt Cloud deployments
- Scheduled data pipeline runs
- CI/CD testing with API credentials
- Automated reporting/alerting
- Cross-repo automation

❌ **Not suitable for:**
- Local development (use `.env` file instead)
- Sharing secrets between team members locally
- Browser-based applications

## Setup Steps

### 1. Add Secrets to GitHub Repository

1. Go to: https://github.com/ckaiser-graniterock/dotfiles
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click: **New repository secret**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DBT_CLOUD_API_TOKEN` | `dbtu_YSkpy...` | dbt Cloud API token |
| `DBT_CLOUD_ACCOUNT_ID` | `2672` | dbt Cloud account ID |
| `DBT_PROJECT_DIR` | `~/da-agent-hub/repos/dbt_cloud` | Path to dbt project |

### 2. Use Secrets in GitHub Actions Workflows

See `.github/workflows/example-secrets-usage.yml` for a complete example.

**Basic usage:**

```yaml
name: My Workflow

on:
  workflow_dispatch:  # Manual trigger

jobs:
  my-job:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Use secrets
        env:
          DBT_CLOUD_API_TOKEN: ${{ secrets.DBT_CLOUD_API_TOKEN }}
          DBT_CLOUD_ACCOUNT_ID: ${{ secrets.DBT_CLOUD_ACCOUNT_ID }}
        run: |
          echo "Account ID: $DBT_CLOUD_ACCOUNT_ID"
          # Your commands here
```

### 3. Test Your Workflow

1. Go to: **Actions** tab in your GitHub repo
2. Select your workflow
3. Click: **Run workflow**
4. Check the logs to verify secrets are working

## Security Best Practices

✅ **DO:**
- Use descriptive secret names (e.g., `DBT_CLOUD_API_TOKEN` not `TOKEN`)
- Rotate secrets regularly
- Use repository secrets for single-repo workflows
- Use organization secrets for multi-repo workflows
- Review workflow logs carefully (secrets are redacted but context might leak info)

❌ **DON'T:**
- Print secret values in logs (`echo $SECRET`)
- Commit secrets to `.env` files
- Share secrets in pull request comments
- Use secrets in workflow file names or descriptions

## Local Development vs CI/CD

**Local Development (your machine):**
```bash
# Use local .env file (git-ignored)
source ~/dotfiles/.env
echo $DBT_CLOUD_ACCOUNT_ID
```

**GitHub Actions (automated workflows):**
```yaml
# Use GitHub Secrets
env:
  DBT_CLOUD_ACCOUNT_ID: ${{ secrets.DBT_CLOUD_ACCOUNT_ID }}
```

## Troubleshooting

### Secret not found error
- Verify secret name matches exactly (case-sensitive)
- Check you added it to the correct repository
- Ensure workflow has permission to access secrets

### Secret value appears as ***
- This is normal! GitHub automatically redacts secret values in logs
- If you need to debug, use indirect verification (check length, first char, etc.)

### Workflow can't access secret
- Check repository settings → Actions → General → Workflow permissions
- Ensure workflows have read access to secrets

## Example Workflows

### Daily dbt Cloud Job Trigger
```yaml
name: Daily dbt Run

on:
  schedule:
    - cron: '0 9 * * 1-5'  # 9 AM weekdays

jobs:
  trigger-dbt:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger dbt Cloud job
        env:
          DBT_CLOUD_API_TOKEN: ${{ secrets.DBT_CLOUD_API_TOKEN }}
          DBT_CLOUD_ACCOUNT_ID: ${{ secrets.DBT_CLOUD_ACCOUNT_ID }}
        run: |
          curl -X POST \
            -H "Authorization: Bearer $DBT_CLOUD_API_TOKEN" \
            "https://cloud.getdbt.com/api/v2/accounts/$DBT_CLOUD_ACCOUNT_ID/jobs/123/run/"
```

## Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions Environment Variables](https://docs.github.com/en/actions/learn-github-actions/variables)
- [Security Hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

## Summary

- ✅ **Local development**: Keep using `~/dotfiles/.env` (git-ignored)
- ✅ **GitHub Actions**: Use GitHub Secrets for automation
- ✅ **Security**: `.env` stays local, secrets stay in GitHub, both stay secure
