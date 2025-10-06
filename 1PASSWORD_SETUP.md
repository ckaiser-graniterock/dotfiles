# 1Password Integration for Dotfiles

Centralized secret management using 1Password for DA Agent Hub credentials.

## Why 1Password?

**Problem**: Managing `.env` files across multiple machines (laptop, desktop, servers) means:
- Manually copying secrets to each machine
- Secrets getting out of sync
- Risk of committing secrets to git

**Solution**: Store secrets in 1Password GRC vault, fetch automatically on each machine.

## Benefits

✅ **One source of truth**: Secrets stored securely in 1Password GRC vault
✅ **Auto-sync**: Update once in 1Password, available everywhere
✅ **No manual `.env` setup**: Secrets load automatically when terminal opens
✅ **Biometric auth**: Touch ID/Face ID instead of typing passwords
✅ **Audit trail**: 1Password tracks when secrets are accessed

## Architecture

```
┌──────────────────────────┐
│   1Password GRC Vault    │
│                          │
│  DA Agent Hub Secrets:   │
│  - DBT_CLOUD_API_TOKEN   │
│  - DBT_CLOUD_ACCOUNT_ID  │
│  - DBT_PROJECT_DIR       │
└──────────┬───────────────┘
           │
           │ 1Password CLI (op)
           │ with biometric auth
           │
     ┌─────▼──────┐
     │  Terminal  │
     │            │
     │  Secrets   │
     │  loaded as │
     │  ENV vars  │
     └────────────┘
```

## Setup (One-Time Per Machine)

### 1. Install 1Password

```bash
# Install 1Password desktop app and CLI
brew install --cask 1password 1password-cli
```

### 2. Configure 1Password App

1. Open 1Password app
2. Sign in to your account
3. Go to: **Settings** → **Developer**
4. Enable: **"Connect with 1Password CLI"** ✅

### 3. Verify GRC Vault Access

```bash
# List vaults (should see GRC)
op vault list

# Should output:
# ID                            NAME
# 6tggnd6yxrbnwb6yt44grat6py    GRC
# ...
```

### 4. Secrets Are Already Stored!

All DA Agent Hub secrets are stored in the **GRC Vault**:

| Item Name | Secrets Stored |
|-----------|----------------|
| **DA Agent Hub - dbt Cloud** | dbt Cloud API token, account ID, project dir |
| **DA Agent Hub - GitHub PAT** | GitHub Personal Access Token |
| **DA Agent Hub - AWS Credentials** | AWS access key ID, secret key, region |
| **DA Agent Hub - Snowflake** | Snowflake account, user, password, database, etc. |

View them:
```bash
op item list --vault="GRC" --tags="da-agent-hub"
op item get "DA Agent Hub - dbt Cloud" --vault="GRC"
op item get "DA Agent Hub - GitHub PAT" --vault="GRC"
op item get "DA Agent Hub - AWS Credentials" --vault="GRC"
```

### 5. Load Secrets Automatically

The `load-secrets-from-1password.sh` script is already added to your `~/.zshrc`:

```bash
# Automatically loads on new terminal session
source ~/dotfiles/load-secrets-from-1password.sh
```

**Test it**: Open a new terminal and run:
```bash
echo $DBT_CLOUD_ACCOUNT_ID           # Should show: 2672
echo $GITHUB_PERSONAL_ACCESS_TOKEN  # Should show: ghp_...
echo $AWS_ACCESS_KEY_ID             # Should show: AKIA...
```

## Daily Usage

### Automatic (Recommended)

Secrets load automatically when you open a terminal. Nothing to do!

### Manual

If you need to reload secrets:
```bash
source ~/dotfiles/load-secrets-from-1password.sh
```

## Adding/Updating Secrets

### Update Existing Secrets

```bash
# Update API token
op item edit "DA Agent Hub - dbt Cloud" \
  --vault="GRC" \
  credential="new_token_here"

# Update account ID
op item edit "DA Agent Hub - dbt Cloud" \
  --vault="GRC" \
  'account_id[text]=new_id'
```

### Add New Secrets

```bash
# Add a new field
op item edit "DA Agent Hub - dbt Cloud" \
  --vault="GRC" \
  'new_field[text]=new_value'
```

Then update `load-secrets-from-1password.sh` to export the new field.

## New Machine Setup

On a new laptop/server:

```bash
# 1. Clone dotfiles
git clone https://github.com/ckaiser-graniterock/dotfiles.git ~/dotfiles

# 2. Install 1Password
brew install --cask 1password 1password-cli

# 3. Open 1Password app, sign in, enable CLI integration

# 4. Add script to shell profile
echo 'source ~/dotfiles/load-secrets-from-1password.sh 2>/dev/null' >> ~/.zshrc

# 5. Restart terminal - secrets auto-load!
```

**That's it!** No manual `.env` file creation needed.

## Troubleshooting

### "1Password CLI not installed"
```bash
brew install --cask 1password-cli
```

### "Cannot access 1Password"
- Make sure 1Password desktop app is running
- Verify CLI integration is enabled: Settings → Developer
- Try running: `op vault list` (may prompt for biometric auth)

### "Item not found"
```bash
# List items in GRC vault
op item list --vault="GRC"

# Check exact item name
op item get "DA Agent Hub - dbt Cloud" --vault="GRC"
```

### Secrets not loading on new terminal
```bash
# Check if script is in .zshrc
grep "load-secrets-from-1password" ~/.zshrc

# If not, add it:
echo 'source ~/dotfiles/load-secrets-from-1password.sh 2>/dev/null' >> ~/.zshrc
```

## Comparison: .env vs 1Password

| Feature | Local `.env` | 1Password |
|---------|-------------|-----------|
| Setup time | Fast (copy file) | Medium (one-time auth) |
| Multi-machine | Manual copy | Automatic sync |
| Updates | Edit on each machine | Update once, sync everywhere |
| Security | Git-ignored | Encrypted in 1Password |
| Authentication | No auth | Biometric (Touch ID) |
| Audit | No tracking | Access logs |
| Team sharing | Share file (insecure) | Share vault (secure) |

## Security Best Practices

✅ **DO:**
- Keep 1Password master password secure
- Enable 2FA on 1Password account
- Use Touch ID/Face ID for CLI authentication
- Regularly rotate API tokens
- Use GRC vault for work secrets

❌ **DON'T:**
- Commit `.env` files to git (still!)
- Share 1Password master password
- Disable CLI integration after setup
- Store personal secrets in GRC vault (use Personal vault)

## Advanced: Multiple Secret Sets

If you need different secrets for different projects:

```bash
# Create separate items
op item create --category="API Credential" \
  --title="Project X - Secrets" \
  --vault="GRC" \
  api_key="key_here"

# Create separate load scripts
cp load-secrets-from-1password.sh load-project-x-secrets.sh

# Edit to fetch from different item
# Then source as needed:
source ~/dotfiles/load-project-x-secrets.sh
```

## Continuous sync

