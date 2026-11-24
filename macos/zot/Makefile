SECRETS := $(HOME)/.secrets/secrets.env
HOMEBREW_PREFIX := $(shell bash -lc 'echo $$HOMEBREW_PREFIX')

ifeq ($(HOMEBREW_PREFIX),)
$(error HOMEBREW_PREFIX is not set in bash env)
endif

HTPASSWD := $(HOMEBREW_PREFIX)/etc/zot/htpasswd

all:
	set -a && . $(SECRETS) && set +a && \
	mkdir -p $(dir $(HTPASSWD)) && \
	/usr/sbin/htpasswd -Bbn "$$DOCKER_REGISTRY_USER" "$$DOCKER_REGISTRY_PASSWORD" > $(HTPASSWD) && \
	chmod 600 $(HTPASSWD)
