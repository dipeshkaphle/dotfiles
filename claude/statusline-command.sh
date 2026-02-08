#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Extract session token usage
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Get git branch (skip optional locks for performance)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        git_branch=" on \033[36m$git_branch\033[0m"
    fi
fi

# Format current directory (show basename and parent)
dir_display=$(echo "$cwd" | awk -F/ '{if (NF > 1) print $(NF-1)"/"$NF; else print $NF}')

# Format token numbers with K suffix for readability
format_tokens() {
    local tokens=$1
    if [ "$tokens" -ge 1000 ]; then
        echo "$((tokens / 1000))K"
    else
        echo "$tokens"
    fi
}

# Build status line
status_line="\033[35m$model\033[0m"

if [ -n "$git_branch" ]; then
    status_line="$status_line$git_branch"
fi

status_line="$status_line in \033[34m$dir_display\033[0m"

# Add session token usage
if [ "$total_input" != "0" ] || [ "$total_output" != "0" ]; then
    total_tokens=$((total_input + total_output))
    formatted_total=$(format_tokens $total_tokens)
    formatted_in=$(format_tokens $total_input)
    formatted_out=$(format_tokens $total_output)
    status_line="$status_line \033[90m[Session: ${formatted_total} tokens (in: ${formatted_in}, out: ${formatted_out})]\033[0m"
fi

# Add context remaining
if [ -n "$context_remaining" ]; then
    context_int=${context_remaining%.*}
    if [ "$context_int" -le 20 ]; then
        color="\033[31m"  # Red for low context
    elif [ "$context_int" -le 50 ]; then
        color="\033[33m"  # Yellow for medium context
    else
        color="\033[32m"  # Green for good context
    fi
    status_line="$status_line ${color}[Context: ${context_remaining}%]\033[0m"
fi

# Output the status line using printf to handle ANSI codes
printf "%b\n" "$status_line"
