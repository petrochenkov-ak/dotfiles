all:
	#bash chmod.sh
	chmod 700 $(HOME)/.ssh/keys/
	chmod 600 $(HOME)/.ssh/keys/*
	find $(HOME)/.ssh -name "*.pub" | sed 's/\.pub//' | xargs -I {} ssh-add --apple-use-keychain {} 2>/dev/null || true
