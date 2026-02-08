#!/usr/bin/env fish
# Preview script for ff (fzf + ripgrep) function
# Expects a single argument in rg output format: file:lineno:content

set -l item $argv[1]
set -l filename (echo $item | cut -d: -f1)
set -l lineno (echo $item | cut -d: -f2)

if not string match -qr '^\d+$' -- $lineno
    echo $item
    exit 0
end

set -l start (math "max(1, $lineno - 5)")
bat --color=always --style=header,grid "$filename" -H $lineno -r "$start:" 2>/dev/null
