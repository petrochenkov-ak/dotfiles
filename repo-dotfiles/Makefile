all:
	find -H "$(HOME)/git" -maxdepth 2 -mindepth 2 -type d ! -name '.scripts' -exec sh -c 'cd "$$1" && "$(HOME)/.local/bin/repo-setup"' _ {} \;
