TARGETS := \
	~/git/petrochenkov-ak/.scripts \
	~/git/petrochenkov-ak-gha/.scripts \
	~/git/petrochenkov-ak-lab/.scripts

.PHONY: all

all:
	for dir in $(TARGETS); do \
		rsync -a --delete --mkpath "$(CURDIR)/scripts/" "$$dir/"; \
	done
