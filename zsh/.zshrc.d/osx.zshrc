if [ -x /opt/homebrew/bin/brew ]; then
	eval `/opt/homebrew/bin/brew shellenv`
fi

if command -v gsed &>/dev/null; then
	alias sed=gsed
fi
