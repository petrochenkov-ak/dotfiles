import sys
import subprocess
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    prompt_arg = sys.argv[1]
    prompt_path = str(Path(prompt_arg).resolve())
    found_paths = set()

    # 1. Запуск базового сканера путей к файлам
    scan_cmd = [sys.executable, "-m", "prompt_files_scan_print", prompt_path]
    try:
        res = subprocess.run(scan_cmd, capture_output=True, text=True, check=True)
        for line in res.stdout.splitlines():
            cleaned = line.strip()
            if cleaned and "deprecated" not in cleaned.lower():
                found_paths.add(cleaned)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(e.stderr)
        sys.exit(e.returncode)

    # 2. Запуск сканера директорий и чтение файлов внутри них
    dir_scan_cmd = [sys.executable, "-m", "prompt_dirs_scan_print", prompt_path]
    try:
        res = subprocess.run(dir_scan_cmd, capture_output=True, text=True, check=True)
        for line in res.stdout.splitlines():
            dir_cleaned = line.strip()
            if dir_cleaned and "deprecated" not in dir_cleaned.lower():
                dir_path = Path(dir_cleaned)
                if dir_path.is_dir():
                    # Рекурсивно находим все файлы в директории
                    for file_path in dir_path.rglob("*"):
                        if file_path.is_file() and "deprecated" not in str(file_path).lower():
                            found_paths.add(str(file_path.resolve()))
    except subprocess.CalledProcessError as e:
        sys.stderr.write(e.stderr)
        sys.exit(e.returncode)

    # 3. Условный запуск Django-сканера
    if "django" in prompt_path.lower():
        django_cmd = [sys.executable, "-m", "prompt_context_django_find", prompt_path]
        try:
            res = subprocess.run(django_cmd, capture_output=True, text=True, check=True)
            for line in res.stdout.splitlines():
                cleaned = line.strip()
                if cleaned and "deprecated" not in cleaned.lower():
                    found_paths.add(cleaned)
        except subprocess.CalledProcessError as e:
            sys.stderr.write(e.stderr)
            sys.exit(e.returncode)

    # 4. Сортировка и вывод результатов
    if found_paths:
        print("\n".join(sorted(found_paths)))

if __name__ == "__main__":
    main()
