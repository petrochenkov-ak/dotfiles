import sys
from pathlib import Path


def main():
    current_dir = Path.cwd()

    # Поиск корневой директории sql
    sql_dir = None
    for parent in [current_dir] + list(current_dir.parents):
        if (parent / "sql").is_dir():
            sql_dir = parent / "sql"
            break

    if not sql_dir and (current_dir / "sql").is_dir():
        sql_dir = current_dir / "sql"

    if (
        not sql_dir
        or not sql_dir.exists()
        or not (schema_root := sql_dir / "src" / "SCHEMA").exists()
    ):
        print(
            "ERROR: 'sql/src/SCHEMA' not found",
            file=sys.stderr,
        )
        sys.exit(1)

    # Обход директорий схем
    for schema_dir in schema_root.iterdir():
        if not schema_dir.is_dir():
            continue

        name_lower = schema_dir.name.lower()
        if not name_lower.endswith("_tasks"):
            continue

        table_dir = schema_dir / "TABLE"
        trigger_dir = schema_dir / "TRIGGER"

        # Собираем имена существующих базовых таблиц
        existing_tables = set()
        if table_dir.exists():
            existing_tables = {f.stem for f in table_dir.glob("*.sql")}

        # Удаляем файлы-сироты из директории TRIGGER
        if trigger_dir.exists():
            for trigger_file in list(trigger_dir.glob("*.sql")):
                table_name = trigger_file.stem

                # Файл триггера устарел, если базовой таблицы больше нет
                is_obsolete = table_name not in existing_tables

                if is_obsolete:
                    try:
                        trigger_file.unlink()
                        print(f"DELETED: {trigger_file}")
                    except Exception as e:
                        print(
                            f"WARNING: Cannot delete {trigger_file}: {e}",
                            file=sys.stderr,
                        )


if __name__ == "__main__":
    main()
