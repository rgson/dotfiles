# Only load on OS X
if [[ $OSTYPE != darwin* ]]; then return; fi


unalias open

alias ll='ls -AlFh -D "%Y-%m-%d %H:%M"'

if [ -x /opt/homebrew/bin/brew ]; then
	eval `/opt/homebrew/bin/brew shellenv`
fi

if command -v gsed &>/dev/null; then
	alias sed=gsed
fi

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
