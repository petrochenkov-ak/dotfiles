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
        partition_dir = schema_dir / "PARTITION"

        # Собираем имена существующих базовых таблиц
        existing_tables = set()
        if table_dir.exists():
            existing_tables = {f.stem for f in table_dir.glob("*.sql")}

        # Удаляем только файлы-сироты из директории PARTITION
        if partition_dir.exists():
            for partition_file in list(partition_dir.glob("*.sql")):
                part_name = partition_file.stem

                base_table_name = None
                if part_name.endswith("_deferred"):
                    base_table_name = part_name[:-9]
                elif part_name.endswith("_critical"):
                    base_table_name = part_name[:-9]

                # Файл сирота, если суффикс не подошел или базовой таблицы нет
                is_obsolete = (
                    base_table_name is None
                    or base_table_name not in existing_tables
                )

                if is_obsolete:
                    try:
                        partition_file.unlink()
                        print(f"DELETED: {partition_file}")
                    except Exception as e:
                        print(
                            f"WARNING: Cannot delete {partition_file}: {e}",
                            file=sys.stderr,
                        )


if __name__ == "__main__":
    main()
