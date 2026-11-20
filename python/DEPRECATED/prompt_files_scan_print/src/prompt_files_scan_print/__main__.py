import os
import re
import sys

# --- Списки исключений для сканирования репозитория ---
IGNORED_DIRS = {
    ".git", ".venv", "venv", "env", ".idea", ".vscode",
    "__pycache__", "node_modules", "build", "dist",
    ".pytest_cache", ".mypy_cache",
}

# Белый список расширений, чтобы отсекать папки вроде VIEW или INDEX
VALID_EXTENSIONS = {
    "py", "sql", "js", "ts", "json", "md", "sh", "txt", "yml", "yaml",
    "conf", "ini", "go", "rs", "c", "h", "cpp", "cs", "rb", "php"
}

# Регулярка ищет только потенциальные имена файлов (слово + точка + расширение)
# Символы слэшей "/" и "\" полностью исключены, чтобы не захватывать пути
POTENTIAL_FILE_PATTERN = re.compile(r'\b[a-zA-Z0-9_\.-]+\.[a-zA-Z0-9]{1,5}\b')

STRIP_CHARS = "`'\"()[]{}.,;:!?*"


def clean_path(raw_path: str) -> str:
    """Удаляет окружающие знаки препинания и кавычки."""
    return raw_path.strip(STRIP_CHARS)


def _is_false_positive(path: str) -> bool:
    """Проверка на ложные срабатывания по расширению и ключевым словам."""
    if not path or path in (".", "..", "/"):
        return True
    if path.startswith("self."):
        return True
    if re.match(r'^[0-9\.]+$', path):
        return True

    if "." in path:
        ext = path.split(".")[-1].lower()
        if ext not in VALID_EXTENSIONS:
            return True

    path_lower = path.lower()
    if "xxx" in path_lower or "example" in path_lower:
        return True

    return False


def find_repo_root(start_path: str = ".") -> str:
    """Ищет корень репозитория вверх по дереву каталогов."""
    current_dir = os.path.abspath(start_path)
    while True:
        if os.path.exists(os.path.join(current_dir, ".git")):
            return current_dir
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:
            return os.path.abspath(start_path)
        current_dir = parent_dir


def get_all_repo_files(repo_root: str) -> list[str]:
    """Собирает все относительные пути файлов внутри репозитория."""
    repo_files = []
    for root, dirs, files in os.walk(repo_root):
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]

        for file in files:
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, repo_root)
            repo_files.append(rel_path.replace("\\", "/"))
    return repo_files


def extract_and_match_paths(prompt_path: str, repo_root: str) -> list[str]:
    """Читает файл, парсит имена файлов и сопоставляет их с репозиторием."""
    if not os.path.exists(prompt_path):
        print(f"ERROR: '{prompt_path}' not found", file=sys.stderr)
        return []

    with open(prompt_path, "r", encoding="utf-8") as f:
        content = f.read()

    repo_files = get_all_repo_files(repo_root)
    potential_filenames = POTENTIAL_FILE_PATTERN.findall(content)
    valid_targets = []

    # Защита: определяем имя самого запускаемого скрипта, чтобы не парсить его текст
    current_script_name = os.path.basename(__file__)

    for raw_name in potential_filenames:
        cleaned_name = clean_path(raw_name)

        # Если нашли имя текущего скрипта — игнорируем его контент
        if cleaned_name == current_script_name or _is_false_positive(cleaned_name):
            continue

        # Берем только имя файла (на случай если в регулярку пролез мусор)
        target_filename = os.path.basename(cleaned_name)

        # Строгое сравнение имени файла с базовым именем файлов в репозитории
        for repo_file in repo_files:
            if os.path.basename(repo_file) == target_filename:
                if repo_file not in valid_targets:
                    valid_targets.append(repo_file)

    return valid_targets


def main():
    # Безопасный сбор аргументов без использования индексов в квадратных скобках
    args = list(sys.argv)
    if len(args) != 2:
        print("usage: python script.py <path_to_file>", file=sys.stderr)
        sys.exit(1)

    prompt_file = args.pop() # Достает последний элемент (путь к файлу)
    repo_root = find_repo_root()
    targets = extract_and_match_paths(prompt_file, repo_root)

    if targets:
        print("\n".join(targets))


if __name__ == "__main__":
    main()
