# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

# 10ms for key sequences, makes C-[ and Esc key pressses instantaneous
KEYTIMEOUT=1
bindkey '^f' beginning-of-line
bindkey '^e' end-of-line

# Allow to move to backward/forward of word
bindkey '^b' backward-word
bindkey '^w' forward-word
bindkey '^h' backward-char
bindkey '^l' forward-char
# bindkey '^j' backward-kill-line # prefer C-u though # emacs vterm gets messed up with this for some reason
# bindkey '^k' kill-line
bindkey '^X^W' kill-word
bindkey '^X^B' vi-backward-kill-word
# bindkey '^X^E' kill-line # this cannot be overrided it seems(it opens editor to edit current command)
bindkey '^X^f' backward-kill-line # prefer C-u though
bindkey '^X^X' kill-line
bindkey '^X^L' clear-screen
export ZIM_HOME=$HOME/.zim/
export EDITOR='nvim'
# keyboard repeat rate 
xset r on
xset r rate 500 50
export BAT_THEME='gruvbox-dark'

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

#
# History

# FZF settings
source $HOME/.nix-profile/share/fzf/key-bindings.zsh
source $HOME/.nix-profile/share/fzf/completion.zsh
export FZF_CTRL_T_OPTS="--reverse --preview '(bat --color=always --style=header,grid --line-range :500 {} ) 2> /dev/null '"
export FZF_DEFAULT_OPTS="--reverse --preview '(bat --color=always --style=header,grid --line-range :500 {} ) 2> /dev/null '"


# USes rg to do fuzzy search in file contents
ff(){
  cmdtorun="echo"
  if [[ "$1" != "" ]]; then
    cmdtorun=$1
  fi
  INITIAL_QUERY=""
  RG_PREFIX="rg --colors 'match:bg:yellow' --line-number --color=always --smart-case "
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    selected=$(fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse \
        --preview "lineno=\$(echo {} | cut -d':' -f2); filename=\$(echo {} | cut -d':' -f1) ; bat --color=always --style=header,grid "\$filename" -H \$lineno -r \$(python -c \"print((lambda x : str(max(0,min(int(x) - 5, int(x)))))(\$(echo \$lineno)))\"):" | cut -d':' -f1,2 --output-delimiter=' ' )
# The cat at the end just prints the <file lineno> of the matched regex 

[[ -n $selected ]] && $cmdtorun $(echo $selected)
}

## Usage: ffopeneditor <editor:emacs/nvim/etc.>
ffopeneditor(){
  EDITOR=$1; ff editorwithlines
}

## Usage: editorwithlines <filename> <lineno>
editorwithlines(){
  $EDITOR +$2 $1
}



# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS
 

#
# Input/output
#


# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}



# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default ${ZDOTDIR:-${HOME}}/.zcompdump is used.
zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# ------------------
# Initialize modules
# ------------------

if [[ ${ZIM_HOME}/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install



# Example aliases
# Some aliases are defined globally so that theyll
# expand inside the functions like copy and vimOut
alias la='exa -a'
alias ll='exa -l'
alias lla='exa -la'
alias ls='exa'
alias tmuxat='tmux a -t'
alias tmux='tmux -u'
alias open='xdg-open'
alias gl='git log --graph --decorate'
alias gs='git status'
alias glo='git log --graph --decorate --oneline'
alias gloa='git log --all --graph --decorate --oneline'




makec(){
  CC=gcc
  if [[ $3 != "" ]]; then
    CC="$3"
  fi
  $CC -lm $2 -o $1 -Wall -Wpedantic -Wextra -fsanitize=address $4
}

makecpp(){
  CC=g++
  if [[ $3 != "" ]]; then
    CC="$3"
  fi
 "$CC" -std=c++2a -lm $2 -o $1 -Wall -Wpedantic -Wextra -fsanitize=address $4
}

mkcd(){
	mkdir $1
	cd $1
}

# Pastes the output of a command to the clipboard
copy(){
	$@ | xclip -selection clipboard
}

# for starship
#https://starship.rs/config/#prompt
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.starship/config.toml


# Requires xinput to be installed
if [ $(uname) = 'Linux' ] ; then
	device_id=$(xinput list | grep Touchpad | gawk 'match($0, /.*id=([0-9]+).*/ , ary) {print ary[1]}')
	for prop_id in $(xinput list-props $device_id | grep 'Tapping Enabled' | head -n 1 | gawk 'match($0, /.*\(([0-9]+)\).*/, ary) {print ary[1]}'); do
		xinput set-prop $device_id $prop_id 1
	done

fi


# Add Stack installed  GHC to path

# export GHC_BIN_PATH=$(stack exec -- which ghc | python -c "print('/'.join(input().split('/')[:-1]))")
export PATH=$PATH:$GHC_BIN_PATH

if [[ $TERM == "xterm-kitty" ]]; then
	alias ssh="TERM='xterm-256color' ssh "
fi

if [[ $TERM == "tmux-256color" ]]; then
	alias ssh="TERM='xterm-256color' ssh "
fi

alias startns2='docker run --rm -ti -v $(pwd):/src  --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" ns2'

start(){
	docker run --rm -ti -v $(pwd):/src  --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" $1
}

# // script to generate compile commands with header info as well
alias make_compile_commands='python ~/scripts/make_compile_commands.py '
alias run_clang_tidy='python ~/scripts/run-clang-tidy.py'
alias expermintal_container='docker run -d -it --privileged experimental'

# opam configuration
[[ ! -r /home/dipesh/.opam/opam-init/init.zsh ]] || source /home/dipesh/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
alias doom='~/.emacs.d/bin/doom'
alias btop='btop -t'
alias monitor='~/dotfiles/watch.sh'



mount_windows_drive(){
  sudo mkdir /run/media/bitlocker; sudo dislocker /dev/nvme0n1p4 -p144793-200739-670736-297363-418330-349877-104093-197428 -- /run/media/bitlocker
  sudo mkdir /run/media/dipesh; sudo mount -t ntfs-3g -o loop /run/media/bitlocker/dislocker-file /run/media/dipesh
}

tmux-window-name() {
	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

export PATH=$PATH:/home/dipesh/.config/coc/extensions/coc-rust-analyzer-data
export PATH=$PATH:/home/dipesh/go/bin

run_emacs_daemon(){
  emacs --daemon
}

emacsclient_tui() {
  DIR="."
  if [[ "$1" != "" ]]; then
    DIR=$1
  fi
  emacsclient -c -t $DIR
}
emacsclient_gui(){
  DIR="."
  if [[ "$1" != "" ]]; then
    DIR=$1
  fi
  emacsclient -c $DIR &
}

emacs_tui(){
  DIR="."
  if [[ "$1" != "" ]]; then
    DIR=$1
  fi
  emacs -nw $DIR
}

emacs_gui(){
  DIR="."
  if [[ "$1" != "" ]]; then
    DIR=$1
  fi
  emacs $DIR &
}

# use this in manjaro to map caps to ctrl
setxkbmap -option caps:ctrl_modifier

search_all_nixpkgs(){
  nix-env --query --available --attr-path
}

[ -f "/home/dipesh/.ghcup/env" ] && . "/home/dipesh/.ghcup/env" # ghcup-env
