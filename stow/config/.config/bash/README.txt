/bin/bash
       The bash executable
/etc/profile
       The systemwide initialization file, executed for login shells

~/.bash_profile
       login shells
~/.bashrc
       interactive non-login shells
~/.bash_logout
       The individual login shell cleanup file, executed when a login shell exits
~/.inputrc
       Individual readline initialization file
~/.bash_prompt

~/.hushlogin

~/.bash_login, ~/.profile
    executed if ~/.bash_profile not exists

OS X Terminal.app runs a login shell by default for each new terminal window, calling .bash_profile instead of .bashrc


# custom files:
bash_aliases
bash_autocomplete
bash_exports
bash_functions
bash_options
bash_prompt

http://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
