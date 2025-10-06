# Dotfiles Repository

Personal configuration files for development environment setup.

## Structure

```
dotfiles/
├── .github/
│   └── workflows/
│       └── example-secrets-usage.yml      # GitHub Actions example
├── claude/
│   └── CLAUDE.md                          # Global Claude Code settings
├── .env.template                          # Environment variables template (committed)
├── .env                                   # Your actual values (local, git-ignored)
├── .gitignore                             # Prevents .env from being committed
├── install.sh                             # Automated setup script
├── load-secrets-from-1password.sh         # Load secrets from 1Password
├── GITHUB_SECRETS.md                      # GitHub Secrets setup guide
├── 1PASSWORD_SETUP.md                     # 1Password integration guide
└── README.md                              # This file
```

## Quick Setup

```bash
# Clone this repo (if not already done)
git clone https://github.com/ckaiser-graniterock/dotfiles.git ~/dotfiles

# Run the install script
cd ~/dotfiles
./install.sh
```

## Manual Setup

### Claude Code Settings

Create symlink to apply global Claude settings:

```bash
# Backup existing settings (if any)
mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup

# Create symlink
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Verify the symlink:
```bash
ls -la ~/.claude/CLAUDE.md
# Should show: ~/.claude/CLAUDE.md -> /Users/[username]/dotfiles/claude/CLAUDE.md
```

### Environment Variables

Configure personal environment variables:

```bash
# The install script automatically creates .env from template
# Edit with your actual values
vim ~/dotfiles/.env

# Verify it's sourced in your shell profile
grep "dotfiles/.env" ~/.zshrc  # or ~/.bashrc
```

**Important**:
- `.env.template` is committed (has placeholders/examples)
- `.env` is git-ignored (has your actual values)
- Never commit API keys or secrets to git

### 1Password Integration (Recommended)

**Better approach**: Store secrets in 1Password, sync automatically across machines.

**Benefits**:
- ✅ One source of truth (GRC vault)
- ✅ Auto-sync across all machines
- ✅ No manual `.env` setup
- ✅ Biometric authentication

**Setup**:
```bash
# Install 1Password
brew install --cask 1password 1password-cli

# Configure (one-time)
# 1. Open 1Password app → Settings → Developer
# 2. Enable "Connect with 1Password CLI"

# Secrets auto-load on terminal open!
source ~/dotfiles/load-secrets-from-1password.sh
```

**See**: `1PASSWORD_SETUP.md` for complete guide

**Comparison**:
- Local `.env`: Fast setup, manual sync across machines
- 1Password: One-time setup, automatic sync everywhere

## What Gets Applied

- **Global Claude Settings**: Security rules, branch protection, personal preferences
- **Environment Variables**: Personal paths, preferences, configuration values
- **ADLC Workflow**: Analytics Development Lifecycle commands and patterns
- **Agent Coordination**: Specialist agent configurations
- **Git Workflows**: Protected branch rules and workflow patterns

## Updating Settings

### Claude Settings (CLAUDE.md)
```bash
# Edit in dotfiles repo
cd ~/dotfiles
vim claude/CLAUDE.md

# Commit changes (this is shared configuration)
git add claude/CLAUDE.md
git commit -m "Update Claude settings"
git push

# Settings automatically apply via symlink
```

### Environment Variables (.env)
```bash
# Edit your personal values
cd ~/dotfiles
vim .env

# NO git commit needed - .env is local only
# Changes apply on next shell session or:
source ~/.zshrc  # or ~/.bashrc
```

### Adding New Environment Variables
```bash
# Add to template (for documentation)
cd ~/dotfiles
vim .env.template

# Commit template changes
git add .env.template
git commit -m "Add new environment variable template"
git push

# Update your local .env with actual value
vim .env
```

## New Machine Setup

1. Clone this repo to `~/dotfiles`
2. Run `./install.sh` (creates symlink and .env from template)
3. Edit `~/dotfiles/.env` with your actual values
4. Restart shell or run `source ~/.zshrc`
5. All settings automatically apply to Claude Code

## Contents

### claude/CLAUDE.md
Global personal preferences for Claude Code including:
- Security & branch protection rules
- Environment variables setup and usage
- ADLC (Analytics Development Lifecycle) workflow
- Agent coordination patterns
- Git workflow standards
- Testing strategies

### .env.template
Template for environment variables:
- Personal preferences (name, communication style)
- Repository paths (dev directory, dbt_cloud, etc.)
- Tool configuration (dbt profile, Snowflake account)
- Optional API keys (with placeholders)

**Note**: Copy this to `.env` and fill in your actual values

### .env (local only)
Your personal environment variable values:
- Git-ignored (never committed)
- Auto-sourced by shell profile
- Contains actual paths, preferences, and secrets

## GitHub Secrets for CI/CD

For automated workflows, you can store secrets in GitHub and access them in GitHub Actions.

**See**: `GITHUB_SECRETS.md` for complete setup guide

**Quick start:**
1. Go to: GitHub repo → Settings → Secrets and variables → Actions
2. Add your secrets (DBT_CLOUD_API_TOKEN, DBT_CLOUD_ACCOUNT_ID, etc.)
3. Use in workflows: `.github/workflows/example-secrets-usage.yml`

**Important**: GitHub Secrets are for automation only - your local `.env` file still needs to be git-ignored and maintained separately.
