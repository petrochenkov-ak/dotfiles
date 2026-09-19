"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import argparse
import ast
import os
import subprocess


def has_executable_code(file_path: str) -> bool:
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            tree = ast.parse(f.read(), filename=file_path)
        return any(
            isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
            for node in ast.walk(tree)
        )
    except Exception:
        return False


def is_valid_file(path: str) -> bool:
    return (
        path.endswith(".py")
        and os.path.exists(path)
        and os.path.basename(path) not in {"__init__.py", "conftest.py"}
        and "test" not in path.lower()
        and "migration" not in path.lower()
    )


def get_all_project_files() -> list[str]:
    git_cmd = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [
        line.strip() for line in git_cmd.stdout.splitlines() if line.strip()
    ]


def get_modified_files() -> list[str]:
    git_cmd = subprocess.run(
        ["git", "status", "--porcelain"],
        capture_output=True,
        text=True,
        check=True,
    )
    files = []
    for line in git_cmd.stdout.splitlines():
        if len(line) < 4:
            continue
        status_flag, path = line[:2], line[3:].strip()
        if status_flag in (" M", "MM", "??"):
            files.append(path)
    return files


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Find Python files for AI type annotation."
    )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--all", action="store_true", help="Scan all project files"
    )
    group.add_argument(
        "--modified",
        action="store_true",
        help="Scan only modified and new files",
    )

    args = parser.parse_args()

    if args.all:
        print("Mode: ALL")
        raw_files = get_all_project_files()
    else:
        print("Mode: MODIFIED")
        raw_files = get_modified_files()

    valid_files = []
    for path in raw_files:
        if is_valid_file(path) and has_executable_code(path):
            valid_files.append(path)

    if not valid_files:
        print("No matching files found.")
        return

    for path in valid_files:
        print(path)


if __name__ == "__main__":
    main()
