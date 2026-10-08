"""
Discover SQL relations in project directories.

Layouts:
1. sql/_build/SCHEMA/{schema}/(FOREIGN TABLE|TABLE|VIEW)/*.sql

Filters: Ignore schemas starting with '_' or ending with '_template'.

AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import sys
from pathlib import Path


def discover_sql_relations() -> list[Path]:
    project_root = Path.cwd()
    sql_dir = project_root / "sql" / "src"

    if not sql_dir.is_dir():
        print("Error: Missing 'sql/_build/'")
        return []

    found_files = []

    schema_path = sql_dir / "SCHEMA"
    if schema_path.is_dir():
        for schema_dir in schema_path.iterdir():
            if schema_dir.is_dir():
                if schema_dir.name.startswith("_") or schema_dir.name.endswith(
                    "_template"
                ):
                    continue

                for subdir in ["FOREIGN TABLE", "TABLE", "VIEW"]:
                    relation_dir = schema_dir / subdir
                    if relation_dir.is_dir():
                        for sql_file in relation_dir.glob("*.sql"):
                            if not sql_file.name.startswith("_"):
                                found_files.append(sql_file)

    return found_files
