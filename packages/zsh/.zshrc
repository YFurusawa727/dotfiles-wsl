# Common env / aliases
[ -f ~/.commonrc ] && source ~/.commonrc

### History (Ubuntu's zsh has no default history file)
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

### Completion
# asdf completion
fpath=("${ASDF_DATA_DIR:-$HOME/.asdf}/completions" $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# gcloud completion
if [ -f /usr/share/google-cloud-sdk/completion.zsh.inc ]; then
    source /usr/share/google-cloud-sdk/completion.zsh.inc
fi

### Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf (Ctrl+T / Alt+C; Ctrl+R is overridden below)
eval "$(fzf --zsh)"

### fzf settings
# history ctrl-r (override fzf default with dedup)
function fzf-history-selection() {
    BUFFER=$(history -n 1 | awk '!a[$0]++' | fzf --tac --no-sort --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

# cdr ctrl-e
[ -d ~/.cache/zsh ] || mkdir -p ~/.cache/zsh
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-file ~/.cache/zsh/chpwd-recent-dirs
zstyle ':chpwd:*' recent-dirs-max 200
function fzf-cdr() {
  local destination=$(cdr -l | sed -e 's/^[[:digit:]]*[[:blank:]]*//' | fzf --query "$LBUFFER")
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N fzf-cdr
bindkey '^E' fzf-cdr

### Prompt
eval "$(starship init zsh)"

# syntax-highlighting must be sourced last
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
