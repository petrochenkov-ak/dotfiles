# ~/Library/Application Support/Sublime Text 3/Packages			MacOS
# %APPDATA%/Roaming/Sublime Text 3/Packages 					Windows
# ~/.config/sublime-text-3/Packages/							Linux

# https://packagecontrol.io/ 		Package Control

UNAME_S:=$(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	PACKAGES:=/Users/$(USER)/Library/Application\ Support/Sublime\ Text\ 3/Packages
else
	PACKAGES:=/Users/$(USER)/.config/sublime-text-3
endif

all:
	cp -R $(CURDIR)/Packages/ $(PACKAGES)
	rsync --delete -a $(CURDIR)/Packages/User/ $(PACKAGES)/User
