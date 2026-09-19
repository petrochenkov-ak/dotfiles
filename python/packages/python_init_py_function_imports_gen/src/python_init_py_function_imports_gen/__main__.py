import argparse
import ast
import sys
from pathlib import Path


def is_ast_equal(code1: str, code2: str) -> bool:
    """Сравнивает два куска кода на уровне AST структуры."""
    if not code1.strip() and not code2.strip():
        return True
    try:
        return ast.dump(ast.parse(code1)) == ast.dump(ast.parse(code2))
    except SyntaxError:
        return code1.strip() == code2.strip()


def process_directory(target_dir: Path) -> None:
    """Генерирует или обновляет __init__.py в указанной директории."""
    cwd_absolute = Path.cwd().resolve()

    # Собираем все публичные .py файлы в папке
    py_files = sorted(
        [
            f
            for f in target_dir.glob("*.py")
            if f.name != "__init__.py" and not f.name.startswith("_")
        ]
    )

    # Генерируем строки импорта одноименных функций: from .имя_модуля import имя_функции
    lines = [f"from .{f.stem} import {f.stem}\n" for f in py_files]
    rendered_code = "".join(lines)

    init_path = target_dir / "__init__.py"
    is_new = not init_path.exists()

    try:
        display_path = init_path.resolve().relative_to(cwd_absolute)
    except ValueError:
        display_path = init_path.resolve()

    if is_new:
        if rendered_code:
            init_path.write_text(rendered_code, encoding="utf-8")
            print(f"NEW: {display_path}")
    else:
        existing_code = init_path.read_text(encoding="utf-8")
        if not is_ast_equal(existing_code, rendered_code):
            init_path.write_text(rendered_code, encoding="utf-8")
            print(f"UPDATED: {display_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate __init__.py with explicit function imports."
    )
    parser.add_argument(
        "dir_path",
        type=str,
        help="Path to the target directory",
    )
    args = parser.parse_args()

    target_dir = Path(args.dir_path)
    if not target_dir.exists() or not target_dir.is_dir():
        print(f"Error: Directory '{args.dir_path}' does not exist.")
        sys.exit(1)

    try:
        process_directory(target_dir)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
