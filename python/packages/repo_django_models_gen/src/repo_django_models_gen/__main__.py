import io
import os
import sys
from pathlib import Path

import black
import dj_database_url
import django
from django.conf import settings
from django.core.management import call_command
from django.core.management.commands.inspectdb import (
    Command as InspectDBCommand,
)
from django.db import connection
import dj_database_url

DATABASE_URL = "postgres://postgres:@127.0.0.1:5433/codegen_local"


if not settings.configured:
    settings.configure(
        DATABASES={
            # Автоматически парсит строку подключения в формат Django
            "default": dj_database_url.config(
                default=DATABASE_URL,
                conn_max_age=600,
                ssl_require=False
            )
        },
        INSTALLED_APPS=[
            "django.contrib.contenttypes",
            "django.contrib.auth",
            "django.contrib.postgres",
        ],
    )
    django.setup()


def discover_sql_relations() -> list[Path]:
    """Ищет SQL-файлы, игнорируя директории схем, заканчивающиеся на _fdw."""
    found_files = []

    for schema_dir in Path("sql/src/SCHEMA").iterdir():
        # Игнорируем файлы и папки внешних таблиц (_fdw)
        if not schema_dir.is_dir() or schema_dir.name.endswith("_fdw"):
            continue

        for ext_type in ["TABLE", "VIEW"]:
            target_dir = schema_dir / ext_type
            if target_dir.exists():
                found_files.extend(target_dir.glob("*.sql"))

    return found_files


def format_with_black(code: str) -> str:
    return black.format_str(code, mode=black.FileMode())


def is_model_code_equal(code_old: str, code_new: str) -> bool:
    return code_old.strip() == code_new.strip()


class CustomInspectDBCommand(InspectDBCommand):
    def handle(self, **options):
        self.seen_columns = {}
        self.auto_now_columns = {}
        self.default_values = {}

        with connection.cursor() as cursor:
            cursor.execute("""
SELECT
    c.relname AS table_name,
    a.attname AS column_name,
    pg_get_expr(d.adbin, d.adrelid) AS default_expression
FROM pg_attribute a
JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
JOIN pg_class c ON a.attrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = current_schema();
                """)
            for table_name, column_name, expr in cursor.fetchall():
                if "now()" in expr:
                    if table_name not in self.auto_now_columns:
                        self.auto_now_columns[table_name] = set()
                    self.auto_now_columns[table_name].add(column_name)

                elif "nextval" not in expr:
                    clean_expr = (
                        expr.split("::")[0]
                        .replace("(", "")
                        .replace(")", "")
                        .replace("'", "")
                        .strip()
                    )

                    if clean_expr.lstrip("-").isdigit():
                        if table_name not in self.default_values:
                            self.default_values[table_name] = {}
                        self.default_values[table_name][column_name] = int(
                            clean_expr
                        )

        return super().handle(**options)

    def get_field_type(self, connection, table_name, row):
        field_type, field_params, field_notes = super().get_field_type(
            connection, table_name, row
        )

        row_name = row.name if hasattr(row, "name") else str(row)

        if (
            table_name in self.auto_now_columns
            and field_type == "DateTimeField"
        ):
            if row_name in self.auto_now_columns[table_name]:
                field_params["auto_now_add"] = True

        if table_name in self.default_values and "Integer" in field_type:
            if row_name in self.default_values[table_name]:
                field_params["default"] = self.default_values[table_name][
                    row_name
                ]

        if table_name not in self.seen_columns:
            with connection.cursor() as cursor:
                columns = [
                    col.name
                    for col in connection.introspection.get_table_description(
                        cursor, table_name
                    )
                ]
            self.seen_columns[table_name] = {
                "has_id": "id" in columns,
                "first_col": columns[0] if columns else None,
            }

        table_info = self.seen_columns[table_name]
        field_params.pop("primary_key", None)

        if table_info["has_id"]:
            if row_name == "id":
                field_params["primary_key"] = True
        else:
            if row_name == table_info["first_col"]:
                field_params["primary_key"] = True

        return field_type, field_params, field_notes


def generate_model_code(schema_name: str, table_name: str) -> str:
    print(f'{schema_name}.{table_name}')
    output_buffer = io.StringIO()
    with connection.cursor() as cursor:
        cursor.execute(f"SET search_path TO {schema_name};")
    cmd = CustomInspectDBCommand(stdout=output_buffer)
    call_command(cmd, table_name, include_views=True)
    raw_code = output_buffer.getvalue()

    if not raw_code.strip() or "class " not in raw_code:
        print(f"ERROR: Failed to inspect {schema_name}.{table_name}\n{raw_code}")
        sys.exit(1)

    clean_lines = []

    for line in raw_code.splitlines():
        if (
            not line.strip()
            or line.strip().startswith("#")
            or "CompositePrimaryKey" in line
        ):
            continue

        if " # " in line:
            line = line.split(" # ")[0]

        if "db_table =" in line:
            indent = len(line) - len(line.lstrip())
            # Изменено: app_label теперь соответствует суффиксу _models_gen
            app_label_line = f"{' ' * indent}app_label = '{schema_name}_models_gen'"
            clean_lines.append(app_label_line)

        clean_lines.append(line.rstrip().rstrip("#").rstrip())

    code = "\n".join(clean_lines).strip()
    code = code.replace(
        "(primary_key=True, blank=True, null=True)", "(primary_key=True)"
    )
    possible_old_lines = [
        f" '{table_name}'",
        f' "{table_name}"',
        f" '{schema_name}.{table_name}'",
        f' "{schema_name}.{table_name}"',
    ]
    for old_line in possible_old_lines:
        new = f'\'"{schema_name}"."{table_name}"\''
        code = code.replace(old_line, f" {new}")

    return format_with_black(code)


def parse_sql_file_path(sql_file_path: Path) -> tuple[str, str]:
    parts = sql_file_path.parts
    schema_index = parts.index("SCHEMA")
    schema = parts[schema_index + 1]
    table = sql_file_path.stem
    return schema, table


def main():
    sql_files = discover_sql_relations()
    packages_root = Path.cwd() / "python" / "packages"

    for sql_file in sql_files:
        schema, table = parse_sql_file_path(sql_file)

        # Изменено: суффикс пакета изменен на _models_gen
        gen_schema = f"{schema}_models_gen"
        py_path = (
            packages_root / gen_schema / "src" / gen_schema / "models" / f"{table}.py"
        )

        code_new = generate_model_code(schema, table)

        if not py_path.exists():
            py_path.parent.mkdir(parents=True, exist_ok=True)
            py_path.write_text(code_new)
            print(f"NEW: {py_path}")
        else:
            code_old = format_with_black(py_path.read_text())
            if not is_model_code_equal(code_old, code_new):
                py_path.write_text(code_new)
                print(f"UPDATED: {py_path}")


if __name__ == "__main__":
    main()
