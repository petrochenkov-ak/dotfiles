import sublime_plugin
import subprocess

# better use
# User/Default.sublime-commands and Default (OSX).sublime-keymap


class Command():

    def get_path(self, paths):
        return self.window.folders()[0]


class OpenTerminalCommand(sublime_plugin.WindowCommand, Command):

    def run(self, paths=[], parameters=None):

        path = self.get_path(paths)

        # ( set -x; open -a Cathode "$PWD" ) # NOT WORK
        # ( set -x; open -a Terminal "$PWD" )
        # ( set -x; open -a iTerm "$PWD" )
        arg = ['open', '-a', 'iTerm', path]
        subprocess.Popen(arg)
