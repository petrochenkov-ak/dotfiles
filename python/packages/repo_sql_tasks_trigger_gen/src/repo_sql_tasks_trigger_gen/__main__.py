import sys
from pathlib import Path


def find_sql_dir(start_dir: Path) -> Path | None:
    """Безопасно ищет директорию sql/src/SCHEMA вверх по дереву."""
    for parent in [start_dir] + list(start_dir.parents):
        if parent.name == "sql" and (parent / "src" / "SCHEMA").exists():
            return parent
        if (parent / "sql" / "src" / "SCHEMA").exists():
            return parent / "sql"
    return None


def main():
    current_dir = Path.cwd()
    sql_dir = find_sql_dir(current_dir)

    if not sql_dir:
        print(
            "ERROR: 'sql/src/SCHEMA' not found in hierarchy",
            file=sys.stderr,
        )
        sys.exit(1)

    # Исходная папка со схемами
    schema_root = sql_dir / "src" / "SCHEMA"
    # Базовая папка для генерации
    gen_root = sql_dir / "src" / "_gen" / "SCHEMA"

    for schema_dir in schema_root.iterdir():
        if not schema_dir.is_dir():
            continue

        name_lower = schema_dir.name.lower()
        if "tasks" not in name_lower:
            continue

        schema_name = schema_dir.name
        table_dir = schema_dir / "TABLE"

        # Целевая директория внутри папки _gen
        trigger_root_dir = gen_root / schema_name / "TRIGGER"

        if not table_dir.exists():
            continue

        table_files = [
            f for f in table_dir.glob("*.sql")
            if "task" in f.stem.lower()
        ]

        if not table_files:
            print(f"INFO: No task .sql files in {table_dir}")
            continue

        # Создаем структуру директорий в _gen, если её еще нет
        trigger_root_dir.mkdir(parents=True, exist_ok=True)

        for table_file in table_files:
            try:
                table_file.read_text(encoding="utf-8")
            except Exception as e:
                print(
                    f"WARNING: Skipping {table_file}: {e}",
                    file=sys.stderr,
                )
                continue

            table_name = table_file.stem

            trigger_name = f"trg_changes_notify"
            file_path = trigger_root_dir / f"{table_name}.sql"

            # SQL-контент только для INSERT и DELETE
            file_content = (
                f"DROP TRIGGER IF EXISTS {trigger_name} ON {schema_name}.{table_name};\n"
                f"CREATE TRIGGER {trigger_name}\n"
                f"AFTER INSERT OR DELETE\n"
                f"ON {schema_name}.{table_name}\n"
                f"FOR EACH STATEMENT\n"
                f"EXECUTE FUNCTION platform_tasks.tasks_changes_notify();\n"
            )

            if not file_path.exists():
                print(f"NEW: {file_path}")
                file_path.write_text(file_content, encoding="utf-8")
            else:
                try:
                    existing_content = file_path.read_text(encoding="utf-8")
                except Exception:
                    existing_content = ""

                if existing_content != file_content:
                    print(f"UPDATED: {file_path}")
                    file_path.write_text(file_content, encoding="utf-8")


if __name__ == "__main__":
    main()
