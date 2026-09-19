all:
	find . -name ".DS_Store" -depth -exec rm {} \;
	find . -name Makefile -mindepth 2 -execdir make all \;
