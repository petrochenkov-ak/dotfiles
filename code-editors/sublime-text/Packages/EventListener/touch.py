#!/usr/bin/env python
# -*- coding: utf-8 -*-
import filecmp
import os
import shutil
import sys
import sublime
import sublime_plugin

# touch parent folders (if content changed)
# how it works:
# on_pre_save: save file to ~/.sublime_on_save
# on_post_save: compare file with ~/.sublime_on_save and touch parent folders if file changed

tmp_file = os.path.join(os.environ["HOME"], ".sublime_on_save")


def is_equal(f1, f2):
    if os.path.exists(f1) and os.path.exists(f2):
        # https://docs.python.org/3/library/filecmp.html
        # returning True if they seem equal
        return filecmp.cmp(f1, f2)


def is_writable(path):
    return os.access(path, os.W_OK)


def touch(path):
    # linux,linux2,win32,cygwin,darwin
    if "darwin" in sys.platform or "linux" in sys.platform:  # Unix
        os.utime(path, None)  # touch (os.utime - Unix only)


def on_pre_save(file_name):
    if os.path.exists(file_name):
        shutil.copyfile(file_name, tmp_file)


def on_post_save(file_name):
    if is_equal(file_name, tmp_file):
        os.unlink(tmp_file)
        return
    path = os.path.dirname(file_name)
    while path and path != "/":
        if is_writable(path):
            touch(path)
        path = os.path.dirname(path)
    if os.path.exists(tmp_file):
        os.unlink(tmp_file)


class Touch(sublime_plugin.EventListener):
    def on_pre_save(self, view):
        try:
            on_pre_save(view.file_name())
        except Exception as e:
            errmsg = "%s\n\n%s: %s" % (__file__, type(e), str(e))
            sublime.error_message(errmsg)

    def on_post_save(self, view):
        try:
            on_post_save(view.file_name())
        except Exception as e:
            errmsg = "%s\n\n%s: %s" % (__file__, type(e), str(e))
            sublime.error_message(errmsg)
