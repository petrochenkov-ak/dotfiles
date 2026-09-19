"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import sys
from pathlib import Path


def _normalize(content: str) -> str:
    return "".join(content.split()).replace(",", "")


def main():
    if len(sys.argv) < 2:
        print("ERROR: Package path argument is required.")
        sys.exit(1)

    package_root = Path(sys.argv[1]).resolve()
    if not package_root.exists():
        print(f"ERROR: {package_root} does not exist.")
        sys.exit(1)

    tasks_dir = package_root / "src" / package_root.name / "tasks"
    if not tasks_dir.is_dir():
        print(f"ERROR: 'tasks' directory not found at {tasks_dir}.")
        sys.exit(1)

    task_modules = []
    for py_file in tasks_dir.glob("*.py"):
        if py_file.name != "__init__.py":
            task_modules.append(py_file.stem)

    if not task_modules:
        print("No task modules found.")
        return

    task_modules.sort()

    tasks_init_path = tasks_dir / "__init__.py"
    is_new = not tasks_init_path.exists()

    init_lines = ["from . import (\n"]
    for task in task_modules:
        init_lines.append(f"    {task},\n")
    init_lines.append(")\n")

    new_content = "".join(init_lines)

    if not is_new:
        with open(tasks_init_path, "r", encoding="utf-8") as f:
            old_content = f.read()
        if _normalize(old_content) == _normalize(new_content):
            return

    with open(tasks_init_path, "w", encoding="utf-8") as f:
        f.write(new_content)

    status = "NEW" if is_new else "UPDATED"
    print(f"{status}: {tasks_init_path.relative_to(package_root)}")


if __name__ == "__main__":
    main()
