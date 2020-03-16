#!/bin/zsh

################################################################################
# Environment

DEFAULT_USER='robin'    # Hidden from prompt

export PATH=~/bin:~/.local/bin:/sbin:/usr/sbin:$PATH

################################################################################
# Alias

alias zmv='noglob zmv -W'

alias ll='ls -AlFh --time-style=long'
alias la='ls -A'
alias l='ls -CF'

alias x='chmod +x'

alias open='xdg-open'

################################################################################
# Basic configuration

setopt extended_glob

autoload -Uz zmv
autoload -Uz add-zsh-hook

WORDCHARS="${WORDCHARS:s#/#}" # Treat / as word separator
REPORTTIME=10 # Report CPU usage for long-running commands (10 seconds)

# History
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Color
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	alias diff='diff --color=auto'
fi

# Locale
export LESSCHARSET=utf-8

################################################################################
# Key bindings

bindkey -e
bindkey '^[[1;5C' emacs-forward-word  # Ctrl + Right
bindkey '^[[1;5D' emacs-backward-word # Ctrl + Left
bindkey '^[[3;5~' kill-word           # Ctrl + Delete
bindkey '^H'      backward-kill-word  # Ctrl + Backspace
bindkey '^@'      _expand_alias       # Ctrl + Space
bindkey '^[[Z'    reverse-menu-complete  # Shift + Tab

if [[ "${terminfo[kcuu1]}" != "" ]]; then  # [Start typing] + Up
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then  # [Start typing] + Down
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

################################################################################
# Terminal title

set_title() {
	[[ $TERM = xterm* ]] || return 1
	print -nf '%b%s%b' '\e]2;' $1 '\a' # tab
	print -nf '%b%s%b' '\e]2;' $1 '\a' # window
}

_precmd_set_title() {
	set_title "${(%):-%15<...<%~%<<}"
}
add-zsh-hook precmd _precmd_set_title

_preexec_set_title() {
	x=$(echo "$2" | sed 's/%/%%/g')
	set_title "${(%):-%15>...>$x%<<}"
}
add-zsh-hook preexec _preexec_set_title

################################################################################
# Prompt

ACTIVE_CHROOT=$(! cat /etc/debian_chroot 2>/dev/null && ischroot && echo chroot)

setopt PROMPT_SUBST

if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
	source /usr/lib/git-core/git-sh-prompt
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWSTASHSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_STATESEPARATOR=' '
fi
_ps_git() {
	type '__git_ps1' &>/dev/null || return
	local info=$(__git_ps1 '%s')
	[[ -n $info ]] || return
	if [[ $info = *$GIT_PS1_STATESEPARATOR* ]]; then
		local state=${info##*$GIT_PS1_STATESEPARATOR}
		info="${info%$GIT_PS1_STATESEPARATOR*} "
		[[ $state =~ '[\*%]' ]] && info+="%F{red}•"
		[[ $state =~ '\+'    ]] && info+="%F{yellow}•"
		[[ $state =~ '\$'    ]] && info+="%F{cyan}•"
	fi
	echo "%B%F{green}$info%b"
}

_precmd_psvar() {
	psvar[1]=$([[ $? = 0 ]] || echo $?)
	psvar[2]=$([[ $USER = $DEFAULT_USER ]] || echo $USER)
	psvar[3]=$SSH_CONNECTION
	psvar[4]=$ACTIVE_CHROOT
}
add-zsh-hook precmd _precmd_psvar

_precmd_prompt_info() {
	local -a p
	p[1]='%(!.%F{red}.%(2V.%F{magenta}.%F{blue}))%n%(3V.%F{magenta}.%F{blue})@%m'
	p[2]='%(4V.%F{magenta}%4v:.)%B%F{yellow}%25<…<%~%<<%b'
	p[3]=$(_ps_git)
	p[4]='%(1V.%B%F{red}⚑%b.)'
	p[5]='%F{black}%D{%k:%M:%S}'
	p=($p)
	print -P "\n${(j. .)p}"
}
add-zsh-hook precmd _precmd_prompt_info

_ps_caret='%B%(!.%F{red}.%(2V.%F{magenta}.%F{blue}))>%b%F{default} '
_ps_context='%B%F{black}%_%b'

PS1="$_ps_caret"
PS2="$_ps_context $_ps_caret"
RPS1=''

################################################################################
# Plugins

for zshrc in ~/.zshrc.d/*.zshrc(N); do
	source $zshrc
done

# Syntax highlighting
if [[ -e /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
	typeset -A ZSH_HIGHLIGHT_STYLES
	ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
fi
