"""
AI Instructions:
1. DO NOT add any comments inside the code or functions.
2. DO NOT generate any docstrings for functions, classes, or methods. Keep only this module-level docstring.
3. All code, explanations, and messages must be strictly in English
4. Keep all log, error, and console output print messages as short and concise as possible.
"""

import io
import os
import tokenize
from typing import List


def remove_comments(file_path: str) -> None:
    with open(file_path, "r", encoding="utf-8") as f:
        source = f.read()
    try:
        tokens = tokenize.generate_tokens(io.StringIO(source).readline)
        clean_tokens: List[tokenize.TokenInfo] = []
        has_changes: bool = False

        for t in tokens:
            if t.type == tokenize.COMMENT:
                if "todo" not in t.string.lower():
                    has_changes = True
                    continue
            clean_tokens.append(t)

        if has_changes:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(tokenize.untokenize(clean_tokens))
    except Exception:
        pass


def main() -> None:
    ignored: set[str] = {".git", ".venv", "venv", "__pycache__"}
    for root, dirs, files in os.walk("."):
        dirs[:] = [
            d for d in dirs if d not in ignored and not d.startswith(".")
        ]
        for file in files:
            if file.endswith(".py"):
                remove_comments(os.path.join(root, file))


if __name__ == "__main__":
    main()
