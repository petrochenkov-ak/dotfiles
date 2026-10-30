all:
	chmod 700 $(HOME)/.ssh/keys/
	chmod 600 $(HOME)/.ssh/keys/*
	find $(HOME)/.ssh -type f -not -name "*.pub" -exec ssh-add --apple-use-keychain {} \; 2>/dev/null || true
