all:
	find $(HOME)/.config $(HOME)/.local -type l ! -exec test -e {} \; -delete
	find $(HOME) -type l -maxdepth 1 ! -exec test -e {} \; -delete
	# brew install stow
	stow --adopt --no-folding --override='.*' --ignore='(daemon\.json|\.DS_Store)' config docker home local ssh -t $(HOME)
	find -L ~/.local/bin -type f -exec chmod +x {} \;
