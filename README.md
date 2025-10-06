# Dotfiles Repository

Personal configuration files for development environment setup.

## Structure

```
dotfiles/
├── claude/
│   └── CLAUDE.md          # Global Claude Code settings
└── install.sh             # Automated setup script
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

## What Gets Applied

- **Global Claude Settings**: Security rules, branch protection, personal preferences
- **ADLC Workflow**: Analytics Development Lifecycle commands and patterns
- **Agent Coordination**: Specialist agent configurations
- **Git Workflows**: Protected branch rules and workflow patterns

## Updating Settings

```bash
# Edit in dotfiles repo
cd ~/dotfiles
vim claude/CLAUDE.md

# Commit changes
git add claude/CLAUDE.md
git commit -m "Update Claude settings"
git push

# Settings automatically apply via symlink
```

## New Machine Setup

1. Clone this repo to `~/dotfiles`
2. Run `./install.sh`
3. All settings automatically apply to Claude Code

## Contents

### claude/CLAUDE.md
Global personal preferences for Claude Code including:
- Security & branch protection rules
- ADLC (Analytics Development Lifecycle) workflow
- Agent coordination patterns
- Git workflow standards
- Testing strategies
