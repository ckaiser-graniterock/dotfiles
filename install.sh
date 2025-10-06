#!/bin/bash

# Dotfiles Installation Script
# Automatically sets up symlinks for configuration files

set -e  # Exit on error

DOTFILES_DIR="$HOME/dotfiles"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Installing dotfiles..."

# Ensure dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Error: Dotfiles directory not found at $DOTFILES_DIR"
    echo "Please clone the repo first:"
    echo "  git clone https://github.com/ckaiser-graniterock/dotfiles.git ~/dotfiles"
    exit 1
fi

# Create .claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "📁 Creating $CLAUDE_DIR directory..."
    mkdir -p "$CLAUDE_DIR"
fi

# Setup Claude settings
echo "🔧 Setting up Claude Code settings..."

# Backup existing CLAUDE.md if it exists and is not a symlink
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    BACKUP_FILE="$CLAUDE_DIR/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backing up existing CLAUDE.md to $BACKUP_FILE"
    mv "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_FILE"
fi

# Create symlink
if [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "🔗 Removing existing symlink..."
    rm "$CLAUDE_DIR/CLAUDE.md"
fi

echo "🔗 Creating symlink: $CLAUDE_DIR/CLAUDE.md -> $DOTFILES_DIR/claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Verify symlink
if [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "✅ Claude settings symlink created successfully!"
    ls -la "$CLAUDE_DIR/CLAUDE.md"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

# Setup environment variables
echo ""
echo "🌍 Setting up environment variables..."

# Create .env from template if it doesn't exist
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    if [ -f "$DOTFILES_DIR/.env.template" ]; then
        echo "📝 Creating .env file from template..."
        cp "$DOTFILES_DIR/.env.template" "$DOTFILES_DIR/.env"
        echo "⚠️  Please edit $DOTFILES_DIR/.env with your actual values"
        echo "   The .env file is git-ignored and stays local to your machine"
    else
        echo "⚠️  Warning: .env.template not found"
    fi
else
    echo "✅ .env file already exists"
fi

# Add source command to shell profile if not already present
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    SOURCE_LINE="# Source dotfiles environment variables"
    SOURCE_CMD="[ -f \"$DOTFILES_DIR/.env\" ] && source \"$DOTFILES_DIR/.env\""

    if ! grep -q "dotfiles/.env" "$SHELL_PROFILE"; then
        echo ""
        echo "📝 Adding .env source to $SHELL_PROFILE..."
        echo "" >> "$SHELL_PROFILE"
        echo "$SOURCE_LINE" >> "$SHELL_PROFILE"
        echo "$SOURCE_CMD" >> "$SHELL_PROFILE"
        echo "✅ Added to shell profile (restart shell or run: source $SHELL_PROFILE)"
    else
        echo "✅ .env already sourced in shell profile"
    fi
fi

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "Your global Claude Code settings are now managed from:"
echo "  $DOTFILES_DIR/claude/CLAUDE.md"
echo ""
echo "Environment variables:"
echo "  $DOTFILES_DIR/.env (edit with your values)"
echo ""
echo "To update settings:"
echo "  1. Edit $DOTFILES_DIR/claude/CLAUDE.md or $DOTFILES_DIR/.env"
echo "  2. Commit and push CLAUDE.md changes to GitHub (never commit .env)"
echo "  3. Changes apply automatically via symlink"
echo ""
echo "Next steps:"
echo "  1. Edit $DOTFILES_DIR/.env with your personal values"
echo "  2. Restart your shell or run: source $SHELL_PROFILE"
