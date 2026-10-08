import os
import re
import sys

# --- Списки исключений для сканирования репозитория ---
IGNORED_DIRS = {
    ".git",
    ".venv",
    "venv",
    "env",
    ".idea",
    ".vscode",
    "__pycache__",
    "node_modules",
    "build",
    "dist",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
}

# Системные файлы и мусор, которые нужно строго игнорировать
IGNORED_FILES = {
    ".ds_store",
    "desktop.ini",
    "thumbs.db",
    "icon\r",  # Специфичный скрытый файл иконки в macOS
    "icon",
}

# --- Константы и Регулярные выражения ---
# Шаблон теперь требует обязательного наличия хотя бы одного слэша '/' внутри пути
POTENTIAL_PATH_PATTERN = re.compile(r'[a-zA-Z0-9_\/-]*\/[a-zA-Z0-9_\/-]*')
STRIP_CHARS = "`'\"()[]{}.,;:!?*/"  # Автоматическое удаление знаков и слэшей по краям


def clean_path(raw_path: str) -> str:
    """Удаляет окружающие знаки препинания, кавычки и крайние слэши."""
    return raw_path.strip(STRIP_CHARS)


def _is_false_positive(path: str) -> bool:
    """Проверка на математические диапазоны, артефакты, ложные срабатывания и примеры."""
    if not path or path in (".", "..", "/"):
        return True

    # Игнорируем слова, если после очистки краев в них не осталось ни одного слэша
    if "/" not in path:
        return True

    # Извлечение имени файла/папки для проверки в черном списке
    base_name = os.path.basename(path).lower().strip()
    if base_name in IGNORED_FILES:
        return True

    if path.startswith("self.") or "/self." in path:
        return True
    if ".." in path:
        return True
    if re.match(r'^[0-9\.]+$', path):
        return True

    path_lower = path.lower()
    if "xxx" in path_lower or "example" in path_lower:
        return True

    return False


def find_repo_root(start_path: str = ".") -> str:
    """Ищет корень репозитория вверх по дереву каталогов (по наличию .git)."""
    current_dir = os.path.abspath(start_path)
    while True:
        if os.path.exists(os.path.join(current_dir, ".git")):
            return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            return os.path.abspath(start_path)
        current_dir = parent_dir


def get_all_repo_dirs(repo_root: str) -> list[str]:
    """Собирает все относительные пути директорий внутри репозитория."""
    repo_dirs = []
    for root, dirs, _ in os.walk(repo_root):
        # Модифицируем dirs inplace, чтобы os.walk не заходил в скрытые папки
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS and not d.startswith('.')]

        for d in dirs:
            full_path = os.path.join(root, d)
            rel_path = os.path.relpath(full_path, repo_root)
            # Приводим к единому стилю слэшей
            repo_dirs.append(rel_path.replace("\\", "/").rstrip("/"))
    return repo_dirs


def find_matching_repo_path(cleaned_path: str, repo_dirs: list[str], repo_root: str) -> str | None:
    """Ищет только строгое полное совпадение пути."""
    # Нормализуем целевой путь из файла
    target = cleaned_path.replace("\\", "/").strip("/")

    # Если путь в файле был абсолютным, делаем его относительным корня репозитория
    if os.path.isabs(cleaned_path):
        normalized_root = repo_root.replace("\\", "/").strip("/")
        if target.startswith(normalized_root):
            # Отрезаем абсолютную часть корня, оставляя относительный путь
            target = target[len(normalized_root):].strip("/")
        else:
            # Абсолютный путь ведет за пределы репозитория
            return None

    # Проверяем строгое равенство относительного пути
    for repo_dir in repo_dirs:
        if repo_dir == target:
            return repo_dir

    return None


def extract_and_match_paths(prompt_path: str, repo_root: str) -> list[str]:
    """Читает файл, парсит потенциальные пути папок и сопоставляет их с директориями репозитория."""
    if not os.path.exists(prompt_path):
        print(f"ERROR: '{prompt_path}' not found", file=sys.stderr)
        return []

    with open(prompt_path, "r", encoding="utf-8") as f:
        content = f.read()

    repo_dirs = get_all_repo_dirs(repo_root)
    potential_paths = POTENTIAL_PATH_PATTERN.findall(content)
    valid_targets = []

    for raw_path in potential_paths:
        cleaned_path = clean_path(raw_path)

        if _is_false_positive(cleaned_path):
            continue

        # Передаем repo_root для корректной обработки абсолютных путей
        matched_path = find_matching_repo_path(cleaned_path, repo_dirs, repo_root)

        if matched_path and matched_path not in valid_targets:
            valid_targets.append(matched_path)

    return valid_targets


def main():
    if len(sys.argv) != 2:
        print("usage: python script.py <path_to_file>", file=sys.stderr)
        sys.exit(1)

    prompt_file = sys.argv[1]
    repo_root = find_repo_root()
    targets = extract_and_match_paths(prompt_file, repo_root)

    if targets:
        print("\n".join(targets))


if __name__ == "__main__":
    main()
