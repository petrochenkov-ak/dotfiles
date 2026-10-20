all:
	find $(HOME)/.config $(HOME)/.local -type l ! -exec test -e {} \; -delete
	find $(HOME) -type l -maxdepth 1 ! -exec test -e {} \; -delete
	find $(HOME)/.config $(HOME)/.local -type d -empty -delete
	rm -fr $(HOME)/.local/share/repo-dotfiles
	# brew install stow
	stow --adopt --no-folding --ignore='(daemon\.json|\.DS_Store)' config docker home local orbstack ssh -t $(HOME)
	find -L ~/.local/bin -type f -exec chmod +x {} \;
