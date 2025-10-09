#!/bin/zsh
# Claude Code Hook Functions - Warcraft II Notifications
# Source this file in your ~/.zshrc to enable sound notifications

# Pre-tool hook - plays "More work?" sound when Claude starts using tools
claude_hook_pre_tool() {
    local tool_name="$1"
    local sound_file="$HOME/dotfiles/claude/sounds/more-work.mp3"

    if [ -f "$sound_file" ]; then
        afplay "$sound_file" &>/dev/null &
    fi
}

# Post-tool hook - plays "Job's done!" sound when Claude finishes using tools
claude_hook_post_tool() {
    local tool_name="$1"
    local result="$2"
    local sound_file="$HOME/dotfiles/claude/sounds/jobs-done.mp3"

    if [ -f "$sound_file" ]; then
        afplay "$sound_file" &>/dev/null &
    fi
}

# Export hook functions as environment variables for Claude Code
export CLAUDE_HOOK_PRE_TOOL="claude_hook_pre_tool"
export CLAUDE_HOOK_POST_TOOL="claude_hook_post_tool"
