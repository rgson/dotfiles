#!/bin/zsh

alias img2jpg='mogrify -format jpg'

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
