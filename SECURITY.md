# Security & Dotfiles Setup Guide

Complete guide to setting up a secure dotfiles repository with centralized secret management using 1Password.

## Table of Contents

- [What is a Dotfiles Repository?](#what-is-a-dotfiles-repository)
- [Why Use 1Password for Secrets?](#why-use-1password-for-secrets)
- [Complete Setup Guide](#complete-setup-guide)
- [Daily Usage](#daily-usage)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

---

## What is a Dotfiles Repository?

A **dotfiles repository** is a version-controlled collection of your personal development configuration files (files that start with `.`, like `.zshrc`, `.gitconfig`, etc.).

### Benefits

✅ **Version control**: Track changes to your configurations over time
✅ **Sync across machines**: Same setup on laptop, desktop, servers
✅ **Backup**: Never lose your configurations
✅ **Share with team**: Standardize development environments
✅ **New machine setup**: Get up and running in minutes

### What Goes in a Dotfiles Repo

**Good candidates:**
- Shell configurations (`.zshrc`, `.bashrc`)
- Git configurations (`.gitconfig`)
- Editor settings (VSCode, Vim)
- Tool configurations (Claude Code settings)
- Setup scripts (`install.sh`)

**NEVER commit:**
- Actual secrets (API keys, passwords, tokens)
- Personal data (SSH private keys, certificates)
- Large binary files

---

## Why Use 1Password for Secrets?

### The Problem with Traditional `.env` Files

**Without centralized secret management:**
```
Laptop .env      Desktop .env      Server .env
    ↓                 ↓                 ↓
Manually copy    Manually copy    Manually copy
Different        Gets outdated    Hard to update
```

**Issues:**
- ❌ Secrets get out of sync across machines
- ❌ Risk of committing secrets to git
- ❌ Manual copying is error-prone
- ❌ No audit trail of who accessed what
- ❌ Difficult to rotate credentials

### With 1Password Integration

```
         1Password GRC Vault
         (One Source of Truth)
                  ↓
    ┌─────────────┼─────────────┐
    ↓             ↓             ↓
  Laptop       Desktop       Server
    ↓             ↓             ↓
Auto-load    Auto-load    Auto-load
```

**Benefits:**
- ✅ One source of truth for all secrets
- ✅ Automatic sync across all machines
- ✅ Biometric authentication (Touch ID/Face ID)
- ✅ Audit trail (1Password logs all access)
- ✅ Easy credential rotation (update once, sync everywhere)
- ✅ Team collaboration (share vault securely)
- ✅ No risk of committing secrets to git

---

## Complete Setup Guide

### Prerequisites

- GitHub account
- 1Password account (free for personal use)
- macOS/Linux/Windows with terminal access

### Step 1: Create Dotfiles Repository

**On GitHub:**
1. Go to https://github.com/new
2. Repository name: `dotfiles`
3. Visibility: **Private** (contains your personal settings)
4. ✅ Create repository (don't initialize with README)

**On your local machine:**
```bash
# Clone the empty repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 2: Install 1Password

```bash
# Install 1Password desktop app and CLI
brew install --cask 1password 1password-cli

# Or download from:
# https://1password.com/downloads
```

### Step 3: Configure 1Password Desktop App

1. **Open 1Password app**
2. **Sign in** (or create account if new)
3. **Enable CLI integration**:
   - Click: **1Password** menu → **Settings** (⌘,)
   - Go to: **Developer** tab
   - Toggle ON: **"Connect with 1Password CLI"** ✅

4. **Verify it works**:
   ```bash
   op whoami
   # Should show your account info

   op vault list
   # Should show your vaults
   ```

### Step 4: Create Vault for Secrets

**Option A - Use existing vault** (like "GRC" for work secrets)

**Option B - Create new vault:**
```bash
# In 1Password app:
# Click "+" → New Vault → Name it (e.g., "Development Secrets")
```

For this guide, we'll use vault name: **GRC**

### Step 5: Store Secrets in 1Password

Store your development credentials in the vault:

```bash
# Example: dbt Cloud credentials
op item create \
  --category="API Credential" \
  --title="DA Agent Hub - dbt Cloud" \
  --vault="GRC" \
  credential="your_dbt_api_token" \
  'account_id[text]=your_account_id' \
  'project_dir[text]=~/path/to/project' \
  --tags="da-agent-hub,dbt,development"

# Example: GitHub Personal Access Token
op item create \
  --category="API Credential" \
  --title="DA Agent Hub - GitHub PAT" \
  --vault="GRC" \
  credential="ghp_your_github_token" \
  'scopes[text]=repo, read:org, read:project' \
  --tags="da-agent-hub,github"

# Example: AWS Credentials
op item create \
  --category="Login" \
  --title="DA Agent Hub - AWS Credentials" \
  --vault="GRC" \
  username="AKIA_YOUR_ACCESS_KEY" \
  password="your_secret_access_key" \
  'region[text]=us-west-2' \
  --tags="da-agent-hub,aws"

# Example: Snowflake with PAT
op item create \
  --category="Database" \
  --title="DA Agent Hub - Snowflake" \
  --vault="GRC" \
  'account[text]=FC41459' \
  'username[text]=YOUR_USER' \
  'password[password]=your_snowflake_pat' \
  'database[text]=YOUR_DATABASE' \
  'schema[text]=YOUR_SCHEMA' \
  'warehouse[text]=YOUR_WAREHOUSE' \
  'role[text]=YOUR_ROLE' \
  'auth_method[text]=password' \
  --tags="da-agent-hub,snowflake"
```

### Step 6: Create Secret Loading Script

Create `~/dotfiles/load-secrets-from-1password.sh`:

```bash
#!/bin/bash

# Load secrets from 1Password vault
set -e

VAULT="GRC"  # Change to your vault name

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔐 Loading secrets from 1Password...${NC}"

# Check 1Password CLI is available
if ! command -v op &> /dev/null; then
    echo -e "${RED}❌ 1Password CLI not installed${NC}"
    exit 1
fi

# Check access to 1Password
if ! op vault list &> /dev/null; then
    echo -e "${RED}❌ Cannot access 1Password${NC}"
    echo "Make sure 1Password app is running and CLI integration is enabled"
    exit 1
fi

# Fetch and export secrets
echo "📥 Fetching secrets from vault: $VAULT"

# Example: dbt Cloud
export DBT_CLOUD_API_TOKEN=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=credential --reveal)
export DBT_CLOUD_ACCOUNT_ID=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=account_id)
export DBT_PROJECT_DIR=$(op item get "DA Agent Hub - dbt Cloud" --vault="$VAULT" --fields label=project_dir)

# Example: GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN=$(op item get "DA Agent Hub - GitHub PAT" --vault="$VAULT" --fields label=credential --reveal)

# Example: AWS
export AWS_ACCESS_KEY_ID=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=username)
export AWS_SECRET_ACCESS_KEY=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=password --reveal)
export AWS_REGION=$(op item get "DA Agent Hub - AWS Credentials" --vault="$VAULT" --fields label=region)
export AWS_DEFAULT_REGION=$AWS_REGION

# Example: Snowflake
export SNOWFLAKE_ACCOUNT=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=account)
export SNOWFLAKE_USER=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=username)
export SNOWFLAKE_PASSWORD=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=password --reveal)
export SNOWFLAKE_DATABASE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=database)
export SNOWFLAKE_SCHEMA=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=schema)
export SNOWFLAKE_WAREHOUSE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=warehouse)
export SNOWFLAKE_ROLE=$(op item get "DA Agent Hub - Snowflake" --vault="$VAULT" --fields label=role)

echo -e "${GREEN}✅ Secrets loaded successfully!${NC}"
```

Make it executable:
```bash
chmod +x ~/dotfiles/load-secrets-from-1password.sh
```

### Step 7: Auto-Load Secrets on Terminal Open

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
# Add this to the end of ~/.zshrc
# Load secrets from 1Password
if [ -f "$HOME/dotfiles/load-secrets-from-1password.sh" ]; then
    source "$HOME/dotfiles/load-secrets-from-1password.sh" 2>/dev/null
fi
```

Apply immediately:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Step 8: Add Other Dotfiles (Optional)

#### Claude Code Settings

```bash
# Copy your global Claude settings to dotfiles
mkdir -p ~/dotfiles/claude
cp ~/.claude/CLAUDE.md ~/dotfiles/claude/CLAUDE.md

# Create symlink
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md

# Verify
ls -la ~/.claude/CLAUDE.md
# Should show: ~/.claude/CLAUDE.md -> /Users/[username]/dotfiles/claude/CLAUDE.md
```

#### Git Configuration

```bash
# Copy git config
cp ~/.gitconfig ~/dotfiles/gitconfig

# Create symlink
ln -sf ~/dotfiles/gitconfig ~/.gitconfig
```

### Step 9: Create Install Script

Create `~/dotfiles/install.sh` for automated setup on new machines:

```bash
#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Installing dotfiles..."

# Ensure dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Dotfiles directory not found"
    echo "Run: git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles"
    exit 1
fi

# Setup Claude Code settings symlink
if [ -f "$DOTFILES_DIR/claude/CLAUDE.md" ]; then
    echo "🔧 Setting up Claude Code settings..."
    mkdir -p "$CLAUDE_DIR"

    # Backup existing if present
    if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
        mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.backup"
    fi

    ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "✅ Claude settings linked"
fi

# Setup shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    SOURCE_CMD='[ -f "$HOME/dotfiles/load-secrets-from-1password.sh" ] && source "$HOME/dotfiles/load-secrets-from-1password.sh" 2>/dev/null'

    if ! grep -q "load-secrets-from-1password" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Load secrets from 1Password" >> "$SHELL_PROFILE"
        echo "$SOURCE_CMD" >> "$SHELL_PROFILE"
        echo "✅ Added secret loading to shell profile"
    fi
fi

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "Next steps:"
echo "  1. Install 1Password: brew install --cask 1password 1password-cli"
echo "  2. Open 1Password app, sign in, enable CLI integration"
echo "  3. Restart terminal or run: source $SHELL_PROFILE"
```

Make it executable:
```bash
chmod +x ~/dotfiles/install.sh
```

### Step 10: Create .gitignore

Create `~/dotfiles/.gitignore` to protect secrets:

```
# Never commit actual secrets
.env

# macOS
.DS_Store

# Backup files
*.backup
*.bak

# Editor files
.vscode/
.idea/
*.swp
*.swo
*~
```

### Step 11: Create README

Create `~/dotfiles/README.md`:

```markdown
# My Dotfiles

Personal development environment configuration.

## Quick Setup

\`\`\`bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run install script
cd ~/dotfiles
./install.sh

# Install 1Password
brew install --cask 1password 1password-cli

# Open 1Password, sign in, enable CLI integration

# Restart terminal
\`\`\`

## Contents

- `claude/CLAUDE.md` - Claude Code global settings
- `load-secrets-from-1password.sh` - Load secrets from 1Password
- `install.sh` - Automated setup script
- `SECURITY.md` - Complete security and setup guide

## Usage

Secrets automatically load when you open a terminal.

To manually reload:
\`\`\`bash
source ~/dotfiles/load-secrets-from-1password.sh
\`\`\`
```

### Step 12: Commit and Push

```bash
cd ~/dotfiles

# Stage all files
git add .

# Commit
git commit -m "Initial dotfiles setup with 1Password integration"

# Push to GitHub
git push -u origin main
```

---

## Daily Usage

### Accessing Secrets

**Automatic** (recommended):
- Open a new terminal
- Secrets load automatically
- Use environment variables in your commands

**Manual**:
```bash
source ~/dotfiles/load-secrets-from-1password.sh
```

### Using Secrets

```bash
# Example: dbt command
dbt run --project-dir $DBT_PROJECT_DIR

# Example: AWS CLI
aws s3 ls  # Uses AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

# Example: Snowflake connection (Python)
import snowflake.connector
conn = snowflake.connector.connect(
    account=os.getenv('SNOWFLAKE_ACCOUNT'),
    user=os.getenv('SNOWFLAKE_USER'),
    password=os.getenv('SNOWFLAKE_PASSWORD'),
    database=os.getenv('SNOWFLAKE_DATABASE'),
    warehouse=os.getenv('SNOWFLAKE_WAREHOUSE')
)
```

### Updating Secrets

**Update in 1Password** (updates everywhere):
```bash
# Update a credential
op item edit "DA Agent Hub - dbt Cloud" \
  --vault="GRC" \
  credential="new_token_here"

# Reload in current shell
source ~/dotfiles/load-secrets-from-1password.sh
```

**Add new secrets**:
```bash
# 1. Add to 1Password vault
op item create --category="API Credential" \
  --title="New Service - API Key" \
  --vault="GRC" \
  credential="your_api_key"

# 2. Update load-secrets-from-1password.sh
vim ~/dotfiles/load-secrets-from-1password.sh
# Add: export NEW_SERVICE_API_KEY=$(op item get "New Service - API Key" --vault="GRC" --fields label=credential --reveal)

# 3. Commit and push
git add load-secrets-from-1password.sh
git commit -m "Add NEW_SERVICE_API_KEY to secrets"
git push
```

### Updating Dotfiles

```bash
# Edit configurations
cd ~/dotfiles
vim claude/CLAUDE.md

# Commit changes
git add .
git commit -m "Update Claude settings"
git push

# Changes apply automatically via symlinks
```

---

## New Machine Setup

Setting up your dotfiles on a new laptop, desktop, or server:

### Step 1: Clone Dotfiles

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
```

### Step 2: Install 1Password

```bash
# On macOS
brew install --cask 1password 1password-cli

# On Linux
# Download from: https://1password.com/downloads/linux

# On Windows
# Download from: https://1password.com/downloads/windows
```

### Step 3: Configure 1Password

1. Open 1Password app
2. Sign in with your account
3. Enable CLI integration (Settings → Developer)

### Step 4: Run Install Script

```bash
cd ~/dotfiles
./install.sh
```

### Step 5: Restart Terminal

```bash
# Close and reopen terminal, or:
source ~/.zshrc  # or ~/.bashrc
```

### Step 6: Verify Secrets Loaded

```bash
echo $DBT_CLOUD_ACCOUNT_ID
echo $GITHUB_PERSONAL_ACCESS_TOKEN
echo $AWS_ACCESS_KEY_ID
echo $SNOWFLAKE_ACCOUNT
```

**That's it!** All your secrets are automatically available.

---

## Security Best Practices

### ✅ DO

1. **Use private GitHub repo** for dotfiles
2. **Use strong 1Password master password**
3. **Enable 2FA** on 1Password account
4. **Use biometric auth** for 1Password CLI
5. **Regularly rotate** API tokens and credentials
6. **Use separate vaults** for work vs personal secrets
7. **Review audit logs** in 1Password periodically
8. **Keep 1Password app updated**
9. **Use descriptive names** for stored items
10. **Tag items** for easy organization

### ❌ DON'T

1. **Never commit `.env` files** with actual secrets
2. **Never commit private keys** (SSH, SSL, etc.)
3. **Don't share 1Password master password** (even with team)
4. **Don't disable 1Password CLI integration** after setup
5. **Don't store secrets in plaintext** anywhere else
6. **Don't use same password** for 1Password and other services
7. **Don't ignore 1Password security warnings**
8. **Don't store personal secrets** in work vaults (or vice versa)

### Checklist

Before committing to dotfiles repo:
```bash
# 1. Check for secrets in files
grep -r "password\|secret\|token\|key" . --exclude-dir=.git

# 2. Verify .gitignore is working
git status  # .env should NOT appear

# 3. Review what's being committed
git diff --cached

# 4. Only commit after verification
git commit -m "Your message"
```

---

## Advanced Configuration

### Multiple Environments

Separate secrets for dev/staging/prod:

```bash
# Create separate vault items
op item create --title="Project - Dev" --vault="GRC" ...
op item create --title="Project - Prod" --vault="GRC" ...

# Create environment-specific load scripts
cp load-secrets-from-1password.sh load-secrets-dev.sh
cp load-secrets-from-1password.sh load-secrets-prod.sh

# Source as needed
source ~/dotfiles/load-secrets-dev.sh
source ~/dotfiles/load-secrets-prod.sh
```

### Team Sharing

Share vault with team members:

1. **In 1Password app**: Right-click vault → Share
2. **Invite team members** via email
3. **Set permissions** (view only, edit, etc.)
4. **Team members** automatically get latest secrets

### GitHub Actions Integration

For CI/CD, use GitHub Secrets (separate from 1Password):

1. **In GitHub repo**: Settings → Secrets → Actions
2. **Add secrets** manually (one-time)
3. **Reference in workflows**:
   ```yaml
   env:
     DBT_CLOUD_API_TOKEN: ${{ secrets.DBT_CLOUD_API_TOKEN }}
   ```

See `GITHUB_SECRETS.md` for details.

### Service Accounts

For servers/automation without interactive login:

```bash
# Create service account in 1Password
# Settings → Service Accounts → Create

# Set token on server
export OP_SERVICE_ACCOUNT_TOKEN="ops_your_token"

# Scripts work automatically
source ~/dotfiles/load-secrets-from-1password.sh
```

---

## Troubleshooting

### "1Password CLI not installed"

**Solution:**
```bash
brew install --cask 1password-cli

# Verify
op --version
```

### "Cannot access 1Password"

**Causes:**
1. 1Password desktop app not running
2. CLI integration not enabled
3. Not signed in to 1Password

**Solution:**
```bash
# 1. Open 1Password app
open -a "1Password"

# 2. Settings → Developer → Enable CLI integration

# 3. Test
op whoami
```

### "Item not found"

**Solution:**
```bash
# List items in vault
op item list --vault="GRC"

# Check exact item name
op item get "Your Item Name" --vault="GRC"
```

### "Secrets not loading on new terminal"

**Solution:**
```bash
# Check if script is in shell profile
grep "load-secrets-from-1password" ~/.zshrc

# If not, add it
echo 'source ~/dotfiles/load-secrets-from-1password.sh 2>/dev/null' >> ~/.zshrc

# Reload
source ~/.zshrc
```

### "Invalid OAuth access token" (Snowflake)

**For Snowflake PAT authentication:**

1. **Use PAT as password** (not with oauth authenticator):
   ```python
   conn = snowflake.connector.connect(
       account='FC41459',
       user='CLAUDE',
       password=os.getenv('SNOWFLAKE_PASSWORD'),  # PAT here
       database=os.getenv('SNOWFLAKE_DATABASE'),
       warehouse=os.getenv('SNOWFLAKE_WAREHOUSE')
   )
   ```

2. **Network policy bypass** (if needed):
   - Go to: Snowflake → Account → Users → [Your User]
   - Click: Programmatic access tokens → [Your PAT]
   - Grant: "Bypass Network Policy Requirement" (24 hours)

3. **Verify PAT is active**:
   - Snowflake → Account → Users → [Your User]
   - Programmatic access tokens tab
   - Status should show "Active"

### Environment variables not persisting

**This is expected for Claude Code tool calls** - each command runs in a fresh shell.

**For your real terminal**: Environment variables persist after sourcing the script.

**Test in your terminal** (not via Claude):
```bash
source ~/dotfiles/load-secrets-from-1password.sh
echo $DBT_CLOUD_ACCOUNT_ID
# Open new terminal - should still work
```

---

## Migration from Local `.env` Files

If you currently have `.env` files:

### Step 1: Inventory Your Secrets

```bash
# Find all .env files
find ~ -name ".env" -type f -not -path "*/node_modules/*"

# Review each one
cat ~/.env
cat ~/project1/.env
cat ~/project2/.env
```

### Step 2: Store in 1Password

For each secret, store in 1Password:
```bash
op item create --category="..." --title="..." --vault="GRC" ...
```

### Step 3: Clear Local `.env` Files

Replace with pointers to 1Password:
```bash
# Example: ~/project/.env
cat > ~/project/.env << 'EOF'
# Secrets now managed via 1Password
# See ~/dotfiles/SECURITY.md for details
#
# To load secrets:
#   source ~/dotfiles/load-secrets-from-1password.sh
EOF
```

### Step 4: Update Scripts

Replace hardcoded secrets with environment variables:

**Before:**
```python
API_KEY = "hardcoded_secret"
```

**After:**
```python
import os
API_KEY = os.getenv('API_KEY')
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub (dotfiles repo)                    │
│  ✅ Committed: Scripts, configs, docs                       │
│  ❌ Never committed: .env with actual secrets                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ git clone / git pull
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   ~/dotfiles/ (local)                        │
│  - claude/CLAUDE.md (symlinked to ~/.claude/)               │
│  - load-secrets-from-1password.sh                           │
│  - install.sh                                               │
│  - .gitignore (protects .env)                               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ ~/.zshrc sources on terminal open
                         │
┌────────────────────────▼────────────────────────────────────┐
│              load-secrets-from-1password.sh                  │
│                                                              │
│  Uses 1Password CLI (op) to fetch secrets                   │
│  Exports as environment variables                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         │ op item get (biometric auth)
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  1Password GRC Vault                         │
│                  (One Source of Truth)                       │
│  ✅ dbt Cloud API token                                     │
│  ✅ GitHub Personal Access Token                            │
│  ✅ AWS credentials                                         │
│  ✅ Snowflake credentials (PAT)                             │
│  ✅ [Any other secrets...]                                  │
└──────────────────────────────────────────────────────────────┘
```

---

## Real-World Example: This Dotfiles Repo

This repository (`ckaiser-graniterock/dotfiles`) follows this exact pattern:

### Structure
```
dotfiles/
├── .github/workflows/
│   └── example-secrets-usage.yml    # GitHub Actions example
├── claude/
│   └── CLAUDE.md                    # Global Claude settings (symlinked)
├── .env.template                    # Template (committed)
├── .env                             # Actual values (git-ignored)
├── .gitignore                       # Protects secrets
├── install.sh                       # Automated setup
├── load-secrets-from-1password.sh   # Load secrets from 1Password
├── 1PASSWORD_SETUP.md               # 1Password integration guide
├── GITHUB_SECRETS.md                # GitHub Actions secrets guide
├── SECRETS_INVENTORY.md             # Complete inventory of stored secrets
├── SECURITY.md                      # This file
└── README.md                        # Overview
```

### Secrets Stored in GRC Vault

| Service | Item Name | What's Stored |
|---------|-----------|---------------|
| dbt Cloud | DA Agent Hub - dbt Cloud | API token, account ID, project path |
| GitHub | DA Agent Hub - GitHub PAT | Personal Access Token |
| AWS | DA Agent Hub - AWS Credentials | Access key, secret key, region |
| Snowflake | DA Agent Hub - Snowflake | Account, user, PAT, database config |

### How It Works

1. **Clone repo** on any machine
2. **Run `./install.sh`** (creates symlinks, sets up shell)
3. **Install 1Password** and sign in
4. **Restart terminal** - all secrets automatically load
5. **Start coding** - no manual secret management needed!

### Security Features

✅ **No secrets in git** - all sensitive data in 1Password
✅ **Automatic sync** - update once, available everywhere
✅ **Biometric auth** - Touch ID/Face ID for access
✅ **Audit trail** - 1Password tracks all access
✅ **Team ready** - share GRC vault with team members

---

## Comparison: Before vs After

### Before 1Password Integration

**Setup on new machine:**
1. Clone repos
2. Find old `.env` files from other machine
3. Manually copy secrets to new machine
4. Hope you copied everything
5. Secrets get out of sync
6. Risk committing secrets to git

**Updating credentials:**
1. Update on laptop
2. Remember to update on desktop
3. Remember to update on servers
4. Miss one machine → things break

### After 1Password Integration

**Setup on new machine:**
1. Clone dotfiles: `git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles`
2. Run install: `./install.sh`
3. Install 1Password and sign in
4. Done! All secrets automatically available

**Updating credentials:**
1. Update in 1Password once
2. Automatically syncs everywhere
3. Reload in active shells: `source ~/dotfiles/load-secrets-from-1password.sh`

---

## FAQ

### Q: Why not just use `.env` files in dotfiles?

**A:** Security risk - if you accidentally push to public repo, all secrets are exposed forever (even if you delete them later, they're in git history).

### Q: Can I use this with my team?

**A:** Yes! Share the GRC vault in 1Password. Everyone gets the same secrets automatically.

### Q: What if 1Password goes down?

**A:** You can still access secrets via 1Password desktop app and manually export. Also, 1Password has excellent uptime and offline mode.

### Q: What about secrets for GitHub Actions?

**A:** Use GitHub Secrets for CI/CD (separate from 1Password). See `GITHUB_SECRETS.md`.

### Q: Can I use other secret managers?

**A:** Yes! The pattern works with:
- HashiCorp Vault
- AWS Secrets Manager
- Doppler
- git-crypt (encrypted files in repo)

### Q: How do I backup my 1Password vault?

**A:** 1Password automatically backs up to cloud. You can also export locally: 1Password → File → Export

### Q: What if I lose my 1Password master password?

**A:** Use your Emergency Kit (provided during account creation). Store it securely offline.

---

## Additional Resources

- **1Password CLI Documentation**: https://developer.1password.com/docs/cli
- **1Password Service Accounts**: https://developer.1password.com/docs/service-accounts
- **Dotfiles Community**: https://dotfiles.github.io
- **Security Best Practices**: https://owasp.org/www-project-secrets-management-cheat-sheet

---

## Support

**Issues with this dotfiles setup?**
- Check `SECRETS_INVENTORY.md` for what's stored
- Check `1PASSWORD_SETUP.md` for detailed 1Password guide
- Check `TROUBLESHOOTING` section above

**1Password support:**
- Documentation: https://support.1password.com
- Community: https://1password.community

---

## License

This is your personal dotfiles repository. Configure as needed for your use case.

**Remember**: Never commit actual secrets - always use 1Password or another secure secret manager!
