#!/usr/bin/env bash

# ~/.bash_logout
#
# bash -l (login shell)
# 	~/.bash_logout sourced on exit
# bash (non-login shell)
#	~/.bash_logout not sourced
#
# check if shell is login: shopt -q login_shell

# { set +x; } 2>/dev/null
# known-issues: $BASH_SOURCE not aviable

