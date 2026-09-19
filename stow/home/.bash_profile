#!/usr/bin/env bash
{ set +x; } 2>/dev/null

# ~/.bash_profile
# .bash_profile is executed for login shells
# .bashrc is executed for interactive non-login shells
# OS X Terminal.app runs a login shell by default for each new terminal window, calling .bash_profile instead of .bashrc

[ -f ~/.config/bash/prompt ] && { . ~/.config/bash/prompt || exit; }
[ -f ~/.bashrc ] && { . ~/.bashrc || exit; }

[ -f ../../../.env ] && { . ../../../.env || exit; }
[ -f ../../.env ] && { . ../../.env || exit; }
[ -f ../.env ] && { . ../.env || exit; }
[ -f .env ] && { . .env || exit; }
:

. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"
