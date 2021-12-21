zimfw() { source /home/dipesh/.zim/zimfw.zsh "${@}" }
fpath=(/home/dipesh/.zim/modules/git/functions /home/dipesh/.zim/modules/utility/functions /home/dipesh/.zim/modules/git-info/functions ${fpath})
autoload -Uz git-alias-lookup git-branch-current git-branch-delete-interactive git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw coalesce git-action git-info
source /home/dipesh/.zim/modules/environment/init.zsh
source /home/dipesh/.zim/modules/git/init.zsh
source /home/dipesh/.zim/modules/input/init.zsh
source /home/dipesh/.zim/modules/termtitle/init.zsh
source /home/dipesh/.zim/modules/utility/init.zsh
source /home/dipesh/.zim/modules/zsh-completions/zsh-completions.plugin.zsh
source /home/dipesh/.zim/modules/completion/init.zsh
source /home/dipesh/.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/dipesh/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/dipesh/.zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
source /home/dipesh/.zim/modules/myPrompt/myPrompt.zsh-theme
