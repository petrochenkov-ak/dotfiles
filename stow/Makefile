all:
	find $(HOME) -maxdepth 4 \( -path "$(HOME)/[!.]*" -o -name ".Trash*" \) -prune -o -type l ! -exec test -e {} \; -delete 2>/dev/null || true
	find $(HOME) -maxdepth 4 \( -path "$(HOME)/[!.]*" -o -name ".Trash*" \) -prune -o -mindepth 2 -type d -empty -delete 2>/dev/null || true
	# brew install stow
	stow --adopt --ignore='(daemon\.json|\.DS_Store)' config docker home local orbstack ssh -t $(HOME)
	find -L ~/.local/bin -type f -exec chmod +x {} \;
