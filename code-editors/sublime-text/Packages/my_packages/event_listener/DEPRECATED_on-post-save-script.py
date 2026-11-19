#!/usr/bin/env python
# -*- coding: utf-8 -*-
import subprocess
import sublime
import sublime_plugin

class OnPostSaveScript(sublime_plugin.EventListener):
    def on_post_save(self, view):
        pass
"""
try:
    args = ["on-post-save",view.file_name()]
    subprocess.check_call(args)
except Exception as e:
    errmsg = "%s\n\n%s: %s" % (__file__, type(e), str(e))
    sublime.error_message(errmsg)
"""
