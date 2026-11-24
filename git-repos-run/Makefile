TARGETS := \
	$(HOME)/git/petrochenkov-ak/.scripts \
	$(HOME)/git/petrochenkov-ak-gha/.scripts \
	$(HOME)/git/petrochenkov-ak-lab/.scripts

.PHONY: all

all:
	for dir in $(TARGETS); do \
		rsync -a --delete --mkpath "$(CURDIR)/scripts/" "$$dir/"; \
		find "$$dir" -name "*.command" -exec chmod +x {} +; \
	done
