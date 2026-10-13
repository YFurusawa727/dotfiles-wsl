# ~/.bashrc: executed by bash for non-login shells.
# zsh is the default shell; this keeps bash usable with the same aliases and prompt.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# Completion
if ! shopt -oq posix && [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Common env / aliases
[ -f ~/.commonrc ] && . ~/.commonrc

# fzf (Ctrl+R / Ctrl+T / Alt+C)
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"

# Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
