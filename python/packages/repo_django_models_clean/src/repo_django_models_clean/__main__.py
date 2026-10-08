import os
import sys
from pathlib import Path

def discover_sql_relations() -> list[Path]:
    """Ищет SQL-файлы, игнорируя директории схем, заканчивающиеся на _fdw."""
    found_files = []

    for schema_dir in Path("sql/src/SCHEMA").iterdir():
        # Игнорируем внешние таблицы (_fdw)
        if not schema_dir.is_dir() or schema_dir.name.endswith("_fdw"):
            continue
        for ext_type in ["TABLE", "VIEW"]:
            target_dir = schema_dir / ext_type
            if target_dir.exists():
                found_files.extend(target_dir.glob("*.sql"))

    return found_files

def parse_sql_file_path(sql_file_path: Path) -> tuple[str, str]:
    parts = sql_file_path.parts
    schema_index = parts.index("SCHEMA")
    schema = parts[schema_index + 1]
    table = sql_file_path.stem
    return schema, table


def main():
    sql_files = discover_sql_relations()

    valid_py_paths = set()
    packages_root = Path.cwd() / "python" / "packages"

    for sql_file in sql_files:
        schema, table = parse_sql_file_path(sql_file)

        # Изменено: Формируем имя сгенерированного пакета по новой конвенции
        gen_schema = f"{schema}_models_gen"
        py_path = (
            packages_root / gen_schema / "src" / gen_schema / "models" / f"{table}.py"
        )
        valid_py_paths.add(py_path.resolve())

    # Изменено: Ищем файлы во всех директориях *_models_gen
    for existing_py in packages_root.glob("*_models_gen/src/*_models_gen/models/*.py"):
        if existing_py.name == "__init__.py":
            continue
        if existing_py.resolve() not in valid_py_paths:
            existing_py.unlink()
            print(f"DELETED: {existing_py}")


if __name__ == "__main__":
    main()
