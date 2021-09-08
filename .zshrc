# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

export EDITOR='nvim'
# keyboard repeat rate 
xset r rate 500 50
export BAT_THEME='gruvbox-dark'

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

#
# History

# FZF settings
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
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
        --preview "bat --color=always --style=header,grid \$(echo {} | cut -d':' -f1) -H \$(echo {} | cut -d':' -f2) -r \$(echo {} | cut -d':' -f2):" | cut -d':' -f1)

  [[ -n $selected ]] && $cmdtorun $selected
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
alias -g la='exa -a'
alias -g ll='exa -l'
alias -g lla='exa -la'
alias tmuxat='tmux a -t'
alias tmux='tmux -u'
alias open='xdg-open'
alias -g lsf='~/scripts/myLs files'
alias -g lsfa='~/scripts/myLs allFiles'
alias -g lsfh='~/scripts/myLs hiddenFiles'
alias -g lsd='~/scripts/myLs dirs'
alias -g lsda='~/scripts/myLs allDirs'
alias -g lsdh='~/scripts/myLs hiddenDirs'
alias gl='git log --graph --decorate'
alias gs='git status'
alias glo='git log --graph --decorate --oneline'
alias gloa='git log --all --graph --decorate --oneline'
alias acad='cd ~/Acads/SEM5'
alias dbmslab='cd ~/Projects/LabsAndAssignments/LabDBMS'
alias netlab='cd ~/Projects/LabsAndAssignments/LabNetworks'
alias clrs_open='zathura "~/Books/CS/Algo/Introduction_to_algorithms-3rd Edition.pdf" &'




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

ruby ~/scripts/touch_pad_enable.rb
export GEM_PATH=/usr/lib/ruby/3.0.0:/home/dipesh/.local/share/gem/ruby/3.0.0/bin
export PATH=$PATH:$GEM_PATH

if [[ $TERM == "xterm-kitty" ]]; then
	alias ssh="TERM='xterm-256color' ssh "
fi

if [[ $TERM == "tmux-256color" ]]; then
	alias ssh="TERM='xterm-256color' ssh "
fi
