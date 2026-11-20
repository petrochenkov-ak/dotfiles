import argparse
from pathlib import Path
import sys

def build_tree_dict(paths: set[Path]) -> dict:
    """Строит вложенный словарь из набора путей."""
    tree = {}
    for path in paths:
        current = tree
        # Разбиваем путь на части относительно текущей папки
        parts = path.parts
        for part in parts:
            if part not in current:
                current[part] = {}
            current = current[part]
    return tree

def print_tree(tree: dict, prefix: str = "", is_top_level: bool = False) -> list[str]:
    """Рекурсивно форматирует дерево в список строк."""
    lines = []

    # Сортируем ключи: сначала папки (у которых есть вложенные словари/дети), потом файлы
    # Для этого проверяем bool(tree[key]), но чтобы пустые папки не улетали вниз,
    # мы полагаемся на то, что у файлов в нашей структуре всегда будет пустой словарь {}.
    # Чтобы точно разделить, можно было бы тащить типы, но для переданных аргументов достаточно алфавита:
    keys = sorted(tree.keys(), key=lambda x: (bool(tree[x]), x.lower()), reverse=True)
    # reverse=True ставит папки (True) вперед файлов (False)

    count = len(keys)
    for index, key in enumerate(keys):
        is_last = (index == count - 1)

        if is_top_level:
            connector = ""
            new_prefix = "" if is_last else "│   "
        else:
            connector = "└── " if is_last else "├── "
            new_prefix = prefix + ("    " if is_last else "│   ")

        lines.append(f"{prefix}{connector}{key}")

        if tree[key]:  # Если есть вложенные элементы
            lines.extend(print_tree(tree[key], new_prefix, is_top_level=False))

    return lines

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="*")
    args = parser.parse_args()

    if not args.paths:
        print("ERROR: No paths provided", file=sys.stderr)
        sys.exit(1)

    # Получаем относительные пути от текущей директории
    relative_paths = []
    cwd = Path.cwd()

    for p in args.paths:
        try:
            # Превращаем в абсолютный, а затем берем относительный путь от корня проекта
            abs_path = Path(p).resolve()
            rel_path = abs_path.relative_to(cwd.resolve())
            relative_paths.append(rel_path)
        except ValueError:
            # Если файл лежит вне текущей папки, пишем ошибку
            print(f"ERROR: Path {p} is outside of current working directory", file=sys.stderr)
            sys.exit(1)

    # Строим дерево из путей
    tree_structure = build_tree_dict(relative_paths)

    # Печатаем
    tree_lines = print_tree(tree_structure, is_top_level=True)

    if tree_lines:
        print("\n".join(tree_lines))

if __name__ == "__main__":
    main()
