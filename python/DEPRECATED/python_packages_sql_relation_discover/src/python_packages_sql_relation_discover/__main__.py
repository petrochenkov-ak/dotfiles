"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import sys

from .utils import discover_sql_relations


def main():
    try:
        sql_files = discover_sql_relations()

        if not sql_files:
            print(
                "Error: No .sql files found matching the patterns.",
                file=sys.stderr,
            )
            sys.exit(1)

        for sql_file in sql_files:
            print(sql_file)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
