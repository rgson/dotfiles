#!/bin/zsh

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

genpasswd() {
	LC_CTYPE=C tr -dc '[:alnum:]' < /dev/urandom | head -c ${1:-16} && echo
}

xungrab() {
	setxkbmap -option grab:break_actions
	xdotool key XF86Ungrab
}
