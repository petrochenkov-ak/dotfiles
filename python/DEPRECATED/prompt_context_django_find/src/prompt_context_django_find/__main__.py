"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English.
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import os
import re
import sys
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("usage: path")
        sys.exit(1)

    prompt_path = Path(sys.argv[1])
    if not prompt_path.exists():
        print(f"ERR: {prompt_path} not found")
        sys.exit(1)

    content = prompt_path.read_text(encoding="utf-8")
    words = set(re.findall(r'\b[A-Za-z0-9_.]+\b', content))

    project_root = Path.cwd()
    found_paths = set()
    target_prefixes = ("models", "serializers", "schemas", "views")

    for root, dirs, files in os.walk(project_root):
        root_path = Path(root)
        parent_dir = root_path.name.lower()

        if "deprecated" in root_path.as_posix().lower():
            continue

        if not any(parent_dir.startswith(p) for p in target_prefixes):
            continue

        for file in files:
            if not file.endswith(".py"):
                continue

            if "deprecated" in file.lower():
                continue

            file_lower = file.lower()
            file_stem_lower = Path(file).stem.lower()

            for word in words:
                word_lower = word.lower()
                if word_lower == file_lower or word_lower == file_stem_lower:
                    full_path = root_path / file
                    rel_path = full_path.relative_to(project_root)

                    if "deprecated" in rel_path.as_posix().lower():
                        continue

                    found_paths.add(str(rel_path))

    if found_paths:
        print("\n".join(sorted(found_paths)))

if __name__ == "__main__":
    main()
