#!/usr/bin/env python3
import subprocess
import sys

def run_git_cmd(args):
    """Безопасно выполняет команду git и возвращает результат."""
    try:
        res = subprocess.run(["git"] + args, capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except subprocess.CalledProcessError:
        return ""

def main():
    # 1. Получаем статус только для подготовленных (staged) файлов в индексе
    status_raw = run_git_cmd(["status", "--porcelain"])
    if not status_raw:
        print("No staged changes found to generate summary.")
        sys.exit(0)

    # Инициализируем списки для хранения путей файлов
    added_files = []
    modified_files = []
    deleted_files = []

    # 2. Парсим строки git status
    for line in status_raw.split("\n"):
        if not line:
            continue

        # Индекс Git (первый символ) показывает статус файла в staged
        staged_status = line[0]
        file_path = line[3:]

        if staged_status == 'A':
            added_files.append(file_path)
        elif staged_status in ('M', 'R'):
            # Включаем сюда измененные (M) и переименованные (R) файлы
            modified_files.append(file_path)
        elif staged_status == 'D':
            deleted_files.append(file_path)

    # Считаем количество файлов для заголовка
    add_count = len(added_files)
    mod_count = len(modified_files)
    del_count = len(deleted_files)

    # 3. Формируем первую строчку (Subject line)
    # Собираем только те части статистики, которые больше нуля, чтобы строка была компактной
    subject_parts = []
    if add_count > 0:
        subject_parts.append(f"add {add_count}")
    if mod_count > 0:
        subject_parts.append(f"mod {mod_count} files")
    if del_count > 0:
        subject_parts.append(f"del {del_count} files")

    # Собираем финальный заголовок по стандарту Conventional Commits
    subject_line = f"chore: {', '.join(subject_parts)}"

    # Выводим первую строчку коммита
    print(subject_line)

    # 4. Формируем тело коммита (Body) со списками файлов построчно
    # Выводим только те секции, в которых реально есть изменения
    if added_files:
        print(f"\nadded {add_count} files:")
        for f in sorted(added_files):
            print(f"+ {f}")

    if modified_files:
        print(f"\nmodified {mod_count} files:")
        for f in sorted(modified_files):
            print(f"~ {f}")

    if deleted_files:
        print(f"\ndeleted {del_count} files:")
        for f in sorted(deleted_files):
            print(f"- {f}")

if __name__ == "__main__":
    main()
