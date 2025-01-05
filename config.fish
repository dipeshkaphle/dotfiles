fish_vi_key_bindings

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
set -x FZF_DEFAULT_OPTS "--reverse --preview '(bat --color=always --style=header,grid --line-range :500 {} ) 2> /dev/null '"

# Fuzzy search using rg
function ff
    set cmdtorun "echo"
    if test (count $argv) -gt 0
        set cmdtorun $argv[1]
    end
    set INITIAL_QUERY ""
    set RG_PREFIX "rg --colors 'match:bg:yellow' --line-number --color=always --smart-case "
    set -l selected (fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse \
        --preview "lineno=\$(echo {} | gcut -d':' -f2); filename=\$(echo {} | gcut -d':' -f1) ; bat --color=always --style=header,grid "\$filename" -H \$lineno -r \$(python3 -c \"print((lambda x : str(max(0,min(int(x) - 5, int(x)))))(\$(echo \$lineno)))\"):" | gcut -d':' -f1,2 --output-delimiter=' ' )
    
    if test -n "$selected"
        eval "$cmdtorun $selected"
    end
end

# Usage: ffopeneditor <editor: emacs/nvim/etc.>
function ffopeneditor
    set EDITOR $argv[1]
    ff editorwithlines
end

# Usage: editorwithlines <filename> <lineno>
function editorwithlines
    $EDITOR +$argv[2] $argv[1]
end

function mkcd
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory-name>"
        return 1
    end

    mkdir $argv[1]
    cd $argv[1]
end

# Set the default editor to Vim
set -x EDITOR vim

# Set the Bat theme
set -x BAT_THEME gruvbox-dark


# Aliases
alias la="eza -a"
alias ll="eza -l"
alias lla="eza -la"
alias ls="eza"
alias tmuxat="tmux a -t"
alias tmux="tmux -u"
alias open="xdg-open"
alias gl="git log --graph --decorate"
alias gs="git status"
alias glo="git log --graph --decorate --oneline"
alias gloa="git log --all --graph --decorate --oneline"


alias doom=$HOME/.config/emacs/bin/doom

fzf --fish | source
direnv hook fish | source

if type -q startship 
    set -x STARSHIP_CONFIG ~/.starship/config.toml
    starship init fish | source
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


function mount_windows_drive
  sudo mkdir /run/media/bitlocker; sudo dislocker /dev/nvme0n1p4 -p144793-200739-670736-297363-418330-349877-104093-197428 -- /run/media/bitlocker
  sudo mkdir /run/media/dipesh; sudo mount -t ntfs-3g -o loop /run/media/bitlocker/dislocker-file /run/media/dipesh
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
end
