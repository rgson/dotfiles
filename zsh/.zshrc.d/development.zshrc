#!/bin/zsh

codemode() {
	gnome-terminal --geometry 80x88+0+0 --tab --working-directory=$1
	code $1
	open $1
	exit
}

godoted() {
	nohup godot --editor --path ${1:-.} >/dev/null 2>&1 &!
}

vagrant() {
	if [[ $@ == 'reboot' ]]; then
		command vagrant halt && vagrant up
	elif [[ $@ == 'renew' ]]; then
		command vagrant destroy -f && vagrant up
	else
		command vagrant $@
	fi
}

validate_yaml() {
	python -c 'import yaml,sys;yaml.safe_load(sys.stdin)' <$1 &>/dev/null \
		|| ( echo "Invalid YAML: $1" && return 1 )
}
