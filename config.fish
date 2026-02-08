fish_vi_key_bindings
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end
fish_add_path "$HOME/.local/bin"
# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set fish_cursor_default block
# Set the insert mode cursor to a line
set fish_cursor_insert line
# Set the replace mode cursors to an underscore
set fish_cursor_replace_one underscore
set fish_cursor_replace underscore
# Set the external cursor to a line. The external cursor appears when a command is started.
# The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
set fish_cursor_external line
# The following variable can be used to configure cursor shape in
# visual mode, but due to fish_cursor_default, is redundant here
set fish_cursor_visual block
set -g fish_escape_delay_ms 10

bind --mode insert \cp up-or-search 
bind --mode insert \cn down-or-search
bind --mode insert \cf beginning-of-line
bind --mode insert \ce end-of-line

# Allow to move to backward/forward of word
bind --mode insert \cb backward-word
bind --mode insert \cw forward-word
bind --mode insert \ch backward-char
bind --mode insert \cl forward-char
# bindkey '^j' backward-kill-line # prefer C-u though # emacs vterm gets messed up with this for some reason
# bindkey '^k' kill-line
bind --mode insert \cX\cW kill-word
bind --mode insert \cX\cB backward-kill-word
# bindkey '^X^E' kill-line # this cannot be overrided it seems(it opens editor to edit current command)
bind --mode insert \cX\cf backward-kill-line # prefer C-u though
bind --mode insert \cX\cX kill-line
bind --mode insert \cX\cL clear-screen

if status is-interactive
    # Commands to run in interactive sessions can go here
end


function run_emacs_daemon
    emacs --daemon
end

function emacsclient_tui
    set DIR "."
    if test (count $argv) -gt 0
        set DIR $argv[1]
    end
    emacsclient -c -t $DIR
end

function emacsclient_gui
    set DIR "."
    if test (count $argv) -gt 0
        set DIR $argv[1]
    end
    emacsclient -c $DIR &
end

function emacs_tui
    set DIR "."
    if test (count $argv) -gt 0
        set DIR $argv[1]
    end
    emacs -nw $DIR
end

function emacs_gui
    set DIR "."
    if test (count $argv) -gt 0
        set DIR $argv[1]
    end
    emacs $DIR &
end


# FZF Options
set -x FZF_CTRL_T_OPTS "--reverse --preview '(bat --color=always --style=header,grid --line-range :500 {} ) 2> /dev/null '"
set -x FZF_DEFAULT_OPTS "--reverse"

# Fuzzy search using rg
function ff
    set -l cmdtorun echo
    if test (count $argv) -gt 0
        set cmdtorun $argv
    end
    set INITIAL_QUERY ""
    set RG_PREFIX "rg --colors 'match:bg:yellow' --line-number --color=always --smart-case "
    set -l preview_script "$HOME/dotfiles/scripts/fzf-rg-preview.fish"
    set -l selected (fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse \
        --preview "$preview_script {}" | awk -F: '{print $1" "$2}' )
    
    if test -n "$selected"
        set -l parts (string split ' ' -- $selected)
        $cmdtorun $parts
    end
end

# Usage: ffopeneditor <editor: emacs/nvim/etc.>
function ffopeneditor
    if test (count $argv) -eq 0
        echo "Usage: ffopeneditor <editor>" >&2
        return 1
    end
    ff _editorwithlines $argv[1]
end

# Usage: _editorwithlines <editor> <filename> <lineno>
function _editorwithlines
    $argv[1] +$argv[3] $argv[2]
end

function mkcd
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory-name>"
        return 1
    end

    mkdir -p $argv[1] && cd $argv[1]
end

# Set the default editor to Vim
set -x EDITOR nvim

# Set the Bat theme
set -x BAT_THEME gruvbox-dark

# Aliases
if type -q eza
    alias la="eza -a"
    alias ll="eza -l"
    alias lla="eza -la"
    alias ls="eza"
end
alias tmuxat="tmux a -t"
alias tmux="command tmux -u"
if type -q xdg-open
    alias open="xdg-open"
end
alias gl="git log --graph --decorate"
alias gs="git status"
alias glo="git log --graph --decorate --oneline"
alias gloa="git log --all --graph --decorate --oneline"


alias doom=$HOME/.config/emacs/bin/doom

if type -q fzf
    fzf --fish | source
end
if type -q direnv
    direnv hook fish | source
end



if type -q uname && test (uname) = "Linux"
	set device_id $(xinput list | grep Touchpad | gawk 'match($0, /.*id=([0-9]+).*/ , ary) {print ary[1]}')
	for prop_id in $(xinput list-props $device_id | grep 'Tapping Enabled' | head -n 1 | gawk 'match($0, /.*\(([0-9]+)\).*/, ary) {print ary[1]}')
		xinput set-prop $device_id $prop_id 1
    end

    xset r on
    xset r rate 500 50
    setxkbmap -option caps:ctrl_modifier
end



function search_all_nixpkgs
  nix-env --query --available --attr-path
end

if type -q fisher
    set -g hydro_color_normal (set_color green)
    set -g hydro_color_git bryellow

    set -g hydro_symbol_prompt "λ"  # Or any other symbol you prefer

    # For vim mode: https://github.com/jorgebucaran/hydro/blob/75ab7168a35358b3d08eeefad4ff0dd306bd80d4/functions/fish_mode_prompt.fish#L9
    set -g fish_color_selection normal --bold --background=brblue
    set -g fish_color_match normal --bold --background=brblue
else
    echo "Fisher plugin manager is not installed." >&2
    echo "Hydro plugin is also not installed(https://github.com/jorgebucaran/hydro)" >&2
end

if type -q opam
    eval (opam env)
end

# opencode
fish_add_path "$HOME/.opencode/bin"

# Source secrets (API keys, etc.)
if test -e "$HOME/dotfiles/secrets.fish"
    source "$HOME/dotfiles/secrets.fish"
end
