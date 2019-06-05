#!/bin/zsh

################################################################################
# Environment

DEFAULT_USER='robin'    # Hidden from prompt

export PATH=~/bin:~/.local/bin:$PATH

################################################################################
# Alias

alias zmv='noglob zmv -W'

alias ll='ls -AlFh --time-style=long'
alias la='ls -A'
alias l='ls -CF'

alias open='xdg-open'

alias img2jpg='mogrify -format jpg'

################################################################################
# Commands

encrypt() {
	out="$1.enc"
	if [ -f $out ]; then
		echo "File $out already exists."
	else
		openssl aes-256-cbc -salt -in $1 -out $out
	fi
}

decrypt() {
	out=${1%*.enc}
	if [ -f $out ]; then
		echo "File $out already exists."
	else
		openssl aes-256-cbc -d -in $1 -out $out
	fi
}

stopwatch() {
	start=$(date +%s)
	while :; do
		echo -ne "$(date -u --date @$(( $(date +%s) - $start)) +%H:%M:%S)\r"
	done
}

wrap80() {
	# $1: line prefix (optional)
	tr '\n' ' ' \
	| fold -w $((80-$#1)) -s \
	| cat - =(echo) \
	| while read i; do echo "$1$i"; done
}

################################################################################
# Basic configuration

setopt extended_glob

autoload -Uz zmv
autoload -Uz add-zsh-hook

WORDCHARS="${WORDCHARS:s#/#}" # Treat / as word separator

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

setopt PROMPT_SUBST
if [[ "$TERM" != "dumb" ]]; then
	autoload -U colors
	colors
fi
if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
	source /usr/lib/git-core/git-sh-prompt
	GIT_PS1_SHOWDIRTYSTATE=1
	GIT_PS1_SHOWSTASHSTATE=1
	GIT_PS1_SHOWUNTRACKEDFILES=1
	GIT_PS1_STATESEPARATOR=' '
fi

_ps_user() {
	local -a parts
	if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
		parts[1]="%{%(!.$fg[red].$fg[magenta])%}%n"
	fi
	if [[ -n "$SSH_CONNECTION" ]]; then
		parts[2]="%{$fg[blue]%}@%{$fg[magenta]%}%m"
	fi
	if [[ -n $parts ]]; then
		echo "%{$bold_color%}${(j..)parts}%{$reset_color%} "
	fi
}

_ps_cwd() {
	echo "%{$fg_bold[yellow]%}%25<…<%~%<<%{$reset_color%} "
}

_ps_git() {
	type '__git_ps1' &>/dev/null || return
	local info=$(__git_ps1 '%s')
	[[ -n $info ]] || return
	if [[ $info = *$GIT_PS1_STATESEPARATOR* ]]; then
		local state=${info##*$GIT_PS1_STATESEPARATOR}
		info="${info%$GIT_PS1_STATESEPARATOR*} "
		[[ $state =~ '[\*%]' ]] && info+="%{$fg[red]%}•"
		[[ $state =~ '\+'    ]] && info+="%{$fg[yellow]%}•"
		[[ $state =~ '\$'    ]] && info+="%{$fg[cyan]%}•"
	fi
	echo "%{$fg_bold[green]%}$info%{$reset_color%} "
}

_ps_status() {
	echo "%(?..%{$fg_bold[red]%}⚑%{$reset_color%} )"
}

_ps_caret() {
	echo "%{$bold_color%(!.$fg[red].$fg[blue])%}>%{$reset_color%} "
}

_ps_context() {
	echo "%{$fg_bold[magenta]%}%_%{$reset_color%} "
}

export PS1='$(_ps_user)$(_ps_cwd)$(_ps_git)$(_ps_status)$(_ps_caret)'
export PS2='$(_ps_context)$(_ps_caret)'
export RPS1=''

_preexec_prompt_timestamp() {
	local zero='%([BSUbfksu]|([FB]|){*})'

	local str_date=$(date +"%H:%M:%S")
	local len_right=$(( ${#str_date} + 1 ))
	local start_right=$(($COLUMNS - $len_right))

	local str_prompt="$(eval echo "$PROMPT")"
	local len_prompt=${#${(S%%)str_prompt//$~zero/}}
	local len_cmd=${#1}
	local len_left=$(($len_cmd + $len_prompt))

	local rdate="\033[${start_right}C ${fg[black]}${str_date}$reset_color"
	if (( $len_left < $start_right )); then
		echo -e "\033[1A$rdate"
	else
		echo -e $rdate
	fi
}
add-zsh-hook preexec _preexec_prompt_timestamp

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
