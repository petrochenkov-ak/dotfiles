import sys
from pathlib import Path


def main():
    current_dir = Path.cwd()

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

    # Определяем корневую директорию для генерации
    gen_root = sql_dir / "src" / "_gen" / "SCHEMA"

    for schema_dir in schema_root.iterdir():
        if not schema_dir.is_dir():
            continue

        name_lower = schema_dir.name.lower()
        if not name_lower.endswith("_tasks"):
            continue

        schema_name = schema_dir.name
        table_dir = schema_dir / "TABLE"

        # Целевая директория для генерации партиций текущей схемы
        partition_dir = gen_root / schema_name / "PARTITION"

        existing_tables = set()
        if table_dir.exists():
            existing_tables = {f.stem for f in table_dir.glob("*.sql")}

        if table_dir.exists() and existing_tables:
            # Создаем структуру _gen/.../PARTITION, если её нет
            partition_dir.mkdir(parents=True, exist_ok=True)

            for table_file in table_dir.glob("*.sql"):
                if not table_file.stem.lower().endswith("_task"):
                    continue

                try:
                    table_file.read_text(encoding="utf-8")
                except Exception as e:
                    print(
                        f"WARNING: Skipping {table_file}: {e}",
                        file=sys.stderr,
                    )
                    continue

                table_name = table_file.stem
                partitions_config = [
                    ("deferred", "FALSE"),
                    ("critical", "TRUE"),
                ]

                for suffix, value in partitions_config:
                    partition_table_name = f"{table_name}_{suffix}"
                    file_path = partition_dir / f"{partition_table_name}.sql"

                    file_content = (
                        f"CREATE TABLE IF NOT EXISTS {schema_name}.{partition_table_name}\n"
                        f"PARTITION OF {schema_name}.{table_name}\n"
                        f"FOR VALUES IN ({value});\n"
                    )

                    if not file_path.exists():
                        print(f"NEW: {file_path}")
                        file_path.write_text(file_content, encoding="utf-8")
                    else:
                        try:
                            existing_content = file_path.read_text(
                                encoding="utf-8"
                            )
                        except Exception:
                            existing_content = ""

                        if existing_content != file_content:
                            print(f"UPDATED: {file_path}")
                            file_path.write_text(
                                file_content, encoding="utf-8"
                            )
        else:
            if table_dir.exists() and not existing_tables:
                print(f"INFO: No .sql files in {table_dir}")


if __name__ == "__main__":
    main()
