#!/bin/zsh

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
