#!/bin/zsh

export BUILDKIT_PROGRESS=plain

godoted() {
	nohup godot --editor --path ${1:-.} >/dev/null 2>&1 &!
}

godoted3() {
	nohup godot3 --editor --path ${1:-.} >/dev/null 2>&1 &!
}

godoted4() {
	nohup godot4 --editor --path ${1:-.} >/dev/null 2>&1 &!
}

validate_yaml() {
	python -c 'import yaml,sys;yaml.safe_load(sys.stdin)' <$1 &>/dev/null \
		|| ( echo "Invalid YAML: $1" && return 1 )
}
