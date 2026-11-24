#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import subprocess
import threading
import time

import sublime
import sublime_plugin


INTERVAL_MS = 10000
SCRIPT = os.path.expanduser("~/.local/bin/gh-pull-main")

last_runs = {}
lock = threading.Lock()
enabled = False


def alert(message):
    print(f"[GhPullMain] ALERT TRIGGERED: {message.strip()}")
    sublime.set_timeout(lambda: sublime.error_message(message), 0)


def run():
    print(f"[GhPullMain] run() вызван. enabled={enabled}")
    if not enabled or not lock.acquire(False):
        if not enabled:
            print("[GhPullMain] Пропуск: плагин выключен")
        else:
            print("[GhPullMain] Пропуск: lock занят другим потоком")
        return

    try:
        windows = [
            (win.id(), win.folders())
            for win in sublime.windows()
            if win.folders()
        ]
        current_ids = {win_id for win_id, folders in windows}
        print(f"[GhPullMain] Активные окна с папками: {current_ids}")

        for win_id in list(last_runs):
            if win_id not in current_ids:
                print(f"[GhPullMain] Удаляем закрытое окно {win_id} из истории запусков")
                last_runs.pop(win_id, None)

        for win_id, folders in windows:
            if not enabled:
                print("[GhPullMain] Цикл прерван: плагин выключили на лету")
                break

            previous = last_runs.get(win_id)
            if previous is not None:
                diff = time.monotonic() - previous
                if diff < INTERVAL_MS / 1000.0:
                    print(f"[GhPullMain] Окно {win_id} пропускаем. Прошло всего {diff:.2f} сек из необходимых {INTERVAL_MS / 1000.0}")
                    continue

            print(f"[GhPullMain] Запускаем скрипт для окна {win_id} в папке: {folders[0]}")
            try:
                # Используем Popen вместо check_output, чтобы гарантированно поймать stderr bash-скрипта
                process = subprocess.Popen(
                    [SCRIPT],
                    cwd=folders[0],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    universal_newlines=True
                )
                stdout, stderr = process.communicate(timeout=5)

                print(f"[GhPullMain] Скрипт завершился с кодом: {process.returncode}")
                if stdout:
                    print(f"[GhPullMain] STDOUT скрипта: {stdout.strip()}")
                if stderr:
                    print(f"[GhPullMain] STDERR скрипта: {stderr.strip()}")

                if process.returncode != 0:
                    # Если bash упал (exit 1), собираем текст ошибки для alert
                    error_payload = stderr.strip() or stdout.strip() or f"Exit code {process.returncode}"
                    alert("Script failed:\n\n{}".format(error_payload))

            except subprocess.TimeoutExpired:
                print("[GhPullMain] Скрипт завис и превысил таймаут 5 секунд")
                alert("Script timeout expired")
            except Exception as error:
                print(f"[GhPullMain] Ошибка subprocess: {error}")
                alert("Execution error:\n{}".format(error))
            finally:
                last_runs[win_id] = time.monotonic()
    except Exception as error:
        print(f"[GhPullMain] Критическая ошибка в try-блоке run(): {error}")
        alert("Plugin error:\n{}".format(error))
    finally:
        lock.release()


def loop():
    if enabled:
        run()
        sublime.set_timeout_async(loop, INTERVAL_MS)


def plugin_loaded():
    global enabled
    enabled = True
    print("[GhPullMain] PLUGIN_LOADED: Плагин инициализирован и запущен")
    sublime.set_timeout_async(loop, 0)


def plugin_unloaded():
    global enabled
    enabled = False
    print("[GhPullMain] PLUGIN_UNLOADED: Плагин выгружен")


class GhPullMainListener(sublime_plugin.EventListener):
    def on_new_window(self, window):
        print("[GhPullMain] Событие: on_new_window")
        sublime.set_timeout_async(run, 0)
        sublime.set_timeout_async(run, 200)

    def on_load_project(self, window):
        print("[GhPullMain] Событие: on_load_project")
        sublime.set_timeout_async(run, 0)

    def on_activated(self, view):
        print("[GhPullMain] Событие: on_activated")
        sublime.set_timeout_async(run, 0)
