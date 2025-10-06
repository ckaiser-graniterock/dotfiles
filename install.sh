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

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "Your global Claude Code settings are now managed from:"
echo "  $DOTFILES_DIR/claude/CLAUDE.md"
echo ""
echo "To update settings:"
echo "  1. Edit $DOTFILES_DIR/claude/CLAUDE.md"
echo "  2. Commit and push changes to GitHub"
echo "  3. Changes apply automatically via symlink"
