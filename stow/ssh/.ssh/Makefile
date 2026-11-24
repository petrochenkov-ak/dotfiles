all:
	chmod 700 $(HOME)/.ssh
	find $(HOME)/.ssh/keys -type d -exec chmod 700 {} +
	find $(HOME)/.ssh/keys -type f -exec chmod 600 {} +
	find $(HOME)/.ssh -type f -not -name "*.pub" -exec ssh-add --apple-use-keychain {} \; 2>/dev/null || true
	grep -viE '^[[:space:]]*(UseKeychain|AddKeysToAgent|IdentityFile)[[:space:]]' $(HOME)/.ssh/config > $(HOME)/.ssh/config.gha
