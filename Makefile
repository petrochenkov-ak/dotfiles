all:
	find . -name ".DS_Store" -depth -exec rm {} \;
	find $(CURDIR) -name "*.command" -exec chmod +x {} \;
	# find . -name Makefile -mindepth 2 -execdir make all \;
